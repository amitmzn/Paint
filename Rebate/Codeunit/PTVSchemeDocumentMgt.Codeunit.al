codeunit 77203 "PTV Scheme Document Mgt"
{
    /// <summary>
    /// Re-evaluates payment clearance on an entitlement.
    /// </summary>
    procedure RefreshPaymentStatus(var Entitlement: Record "PTV Scheme Entitlement"): Boolean
    var
        SchemeHdr: Record "PTV Scheme Header";
        GrowthPayGate: Codeunit "PTV Scheme Growth & Pay Gate";
        UnpaidAmt: Decimal;
        Cleared: Boolean;
    begin
        SchemeHdr.Get(Entitlement."Scheme Code");
        Cleared := GrowthPayGate.CheckPaymentCleared(
            SchemeHdr, Entitlement."Customer No.", Entitlement."Period Start Date", Entitlement."Period End Date",
            Entitlement."Entry No.", UnpaidAmt);
        Entitlement."Payment Cleared" := Cleared;
        Entitlement."Unpaid Invoice Amount" := UnpaidAmt;
        Entitlement.Modify();
        exit(Cleared);
    end;

    /// <summary>
    /// Approves an open entitlement after verifying growth, optional mix, and payment clearance.
    /// </summary>
    procedure ApproveEntitlement(var Entitlement: Record "PTV Scheme Entitlement")
    var
        SchemeHdr: Record "PTV Scheme Header";
        GrowthNotMetErr: Label 'Customer %1 did not meet the mandatory YoY growth requirement (%2%).';
        UnpaidInvoicesErr: Label 'Customer %1 has unpaid invoices of %2 for the scheme period. Payment must be received before approval.';
        MixNotMetErr: Label 'Customer %1 did not meet the configured product mix thresholds (Luxury %2%, Premium %3%, Budget %4%).';
        StatusErr: Label 'Only Open or Pending Approval entitlements can be approved.';
    begin
        if not (Entitlement.Status in [Entitlement.Status::Open, Entitlement.Status::"Pending Approval"]) then
            Error(StatusErr);

        SchemeHdr.Get(Entitlement."Scheme Code");
        if SchemeHdr."Require Growth Check" and not Entitlement."Growth Qualified" then
            Error(GrowthNotMetErr, Entitlement."Customer No.", Entitlement."Growth %");

        if not RefreshPaymentStatus(Entitlement) then
            Error(UnpaidInvoicesErr, Entitlement."Customer No.", Entitlement."Unpaid Invoice Amount");

        if SchemeHdr."Enforce Product Mix" then
            if (Entitlement."Luxury Mix %" < SchemeHdr."Luxury Mix Target %") or
               (Entitlement."Premium Mix %" < SchemeHdr."Premium Mix Target %") or
               (Entitlement."Budget Mix %" < SchemeHdr."Budget Mix Target %")
            then
                Error(MixNotMetErr, Entitlement."Customer No.", Entitlement."Luxury Mix %", Entitlement."Premium Mix %", Entitlement."Budget Mix %");

        Entitlement.Status := Entitlement.Status::Approved;
        Entitlement."Approved By" := CopyStr(UserId(), 1, MaxStrLen(Entitlement."Approved By"));
        Entitlement."Approved On" := CurrentDateTime();
        Entitlement.Modify(true);
    end;

    /// <summary>
    /// Creates a Sales Credit Memo for an approved entitlement with Reward Choice = Credit Note.
    /// </summary>
    procedure CreateCreditMemo(var Entitlement: Record "PTV Scheme Entitlement"): Code[20]
    var
        SchemeHdr: Record "PTV Scheme Header";
        RebateSetup: Record "PTV Rebate Setup";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        AppliedEntry: Record "PTV Scheme Applied Entry";
        GLAccountNo: Code[20];
        NotApprovedErr: Label 'Entitlement %1 must be Approved before creating a credit memo.';
        WrongChoiceErr: Label 'Entitlement %1 has Reward Choice = %2; Credit Note is required.';
        AlreadyCreatedErr: Label 'Credit Memo %1 has already been created for entitlement %2.';
        NoAmountErr: Label 'Total Rebate Amount must be greater than zero.';
        MissingGLErr: Label 'Configure Rebate G/L Account on Scheme %1 or in Rebate & Scheme Setup.';
    begin
        if Entitlement.Status <> Entitlement.Status::Approved then
            Error(NotApprovedErr, Entitlement."Entry No.");
        if Entitlement."Reward Choice" <> Entitlement."Reward Choice"::"Credit Note" then
            Error(WrongChoiceErr, Entitlement."Entry No.", Entitlement."Reward Choice");
        if Entitlement."Credit Memo No." <> '' then
            Error(AlreadyCreatedErr, Entitlement."Credit Memo No.", Entitlement."Entry No.");
        if Entitlement."Total Rebate Amount" <= 0 then
            Error(NoAmountErr);

        SchemeHdr.Get(Entitlement."Scheme Code");
        RebateSetup.GetSetup();
        GLAccountNo := SchemeHdr."Rebate G/L Account";
        if GLAccountNo = '' then
            GLAccountNo := RebateSetup."Default Rebate G/L Account";
        if GLAccountNo = '' then
            Error(MissingGLErr, SchemeHdr.Code);

        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::"Credit Memo";
        SalesHeader."No." := '';
        SalesHeader.Insert(true);
        SalesHeader.Validate("Sell-to Customer No.", Entitlement."Customer No.");
        SalesHeader.Validate("Posting Date", WorkDate());
        if SchemeHdr."Posted Credit Memo Nos." <> '' then
            SalesHeader.Validate("Posting No. Series", SchemeHdr."Posted Credit Memo Nos.");
        SalesHeader."External Document No." := CopyStr(SchemeHdr.Code, 1, MaxStrLen(SalesHeader."External Document No."));
        SalesHeader."Posting Description" := CopyStr(StrSubstNo('%1 (%2..%3)', SchemeHdr.Description, Entitlement."Period Start Date", Entitlement."Period End Date"), 1, MaxStrLen(SalesHeader."Posting Description"));
        SalesHeader.Modify(true);

        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := 10000;
        SalesLine.Insert(true);
        SalesLine.Validate(Type, SalesLine.Type::"G/L Account");
        SalesLine.Validate("No.", GLAccountNo);
        SalesLine.Validate(Quantity, 1);
        SalesLine.Validate("Unit Price", Entitlement."Total Rebate Amount");
        SalesLine.Description := CopyStr(StrSubstNo('Scheme %1 - %2', SchemeHdr.Code, SchemeHdr.Description), 1, MaxStrLen(SalesLine.Description));
        if SchemeHdr."Suppress VAT on Credit Notes" or RebateSetup."Suppress VAT on Credit Notes" then begin
            SalesLine.Validate("VAT Bus. Posting Group", '');
            SalesLine.Validate("VAT Prod. Posting Group", '');
        end;
        SalesLine.Modify(true);

        Entitlement.Status := Entitlement.Status::"Credit Note Created";
        Entitlement."Credit Memo No." := SalesHeader."No.";
        Entitlement.Modify(true);

        AppliedEntry.Init();
        AppliedEntry."Entitlement Entry No." := Entitlement."Entry No.";
        AppliedEntry."Scheme Code" := Entitlement."Scheme Code";
        AppliedEntry."Customer No." := Entitlement."Customer No.";
        AppliedEntry."Source Document Type" := AppliedEntry."Source Document Type"::"Target Credit Memo";
        AppliedEntry."Document No." := SalesHeader."No.";
        AppliedEntry."Document Line No." := SalesLine."Line No.";
        AppliedEntry."Posting Date" := SalesHeader."Posting Date";
        AppliedEntry."Net Amount" := Entitlement."Total Rebate Amount";
        AppliedEntry.Insert(true);

        exit(SalesHeader."No.");
    end;

    /// <summary>
    /// Creates an FOC Sales Order for an approved entitlement with Reward Choice = FOC Order.
    /// </summary>
    procedure CreateFOCSalesOrder(var Entitlement: Record "PTV Scheme Entitlement"): Code[20]
    var
        SchemeHdr: Record "PTV Scheme Header";
        RebateSetup: Record "PTV Rebate Setup";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        AppliedEntry: Record "PTV Scheme Applied Entry";
        ReasonCode: Code[10];
        NotApprovedErr: Label 'Entitlement %1 must be Approved before creating an FOC order.';
        WrongChoiceErr: Label 'Entitlement %1 has Reward Choice = %2; FOC Order is required.';
        AlreadyCreatedErr: Label 'FOC Sales Order %1 has already been created for entitlement %2.';
        NoFOCQtyErr: Label 'FOC Item No. and FOC Quantity must be populated.';
    begin
        if Entitlement.Status <> Entitlement.Status::Approved then
            Error(NotApprovedErr, Entitlement."Entry No.");
        if Entitlement."Reward Choice" <> Entitlement."Reward Choice"::"FOC Order" then
            Error(WrongChoiceErr, Entitlement."Entry No.", Entitlement."Reward Choice");
        if Entitlement."FOC Sales Order No." <> '' then
            Error(AlreadyCreatedErr, Entitlement."FOC Sales Order No.", Entitlement."Entry No.");
        if (Entitlement."FOC Item No." = '') or (Entitlement."FOC Quantity" <= 0) then
            Error(NoFOCQtyErr);

        SchemeHdr.Get(Entitlement."Scheme Code");
        RebateSetup.GetSetup();
        ReasonCode := SchemeHdr."FOC Reason Code";
        if ReasonCode = '' then
            ReasonCode := RebateSetup."FOC Reason Code";

        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
        SalesHeader."No." := '';
        SalesHeader.Insert(true);
        SalesHeader.Validate("Sell-to Customer No.", Entitlement."Customer No.");
        SalesHeader.Validate("Posting Date", WorkDate());
        if ReasonCode <> '' then
            SalesHeader.Validate("Reason Code", ReasonCode);
        SalesHeader."External Document No." := CopyStr(SchemeHdr.Code, 1, MaxStrLen(SalesHeader."External Document No."));
        SalesHeader.Modify(true);

        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := 10000;
        SalesLine.Insert(true);
        SalesLine.Validate(Type, SalesLine.Type::Item);
        SalesLine.Validate("No.", Entitlement."FOC Item No.");
        if Entitlement."FOC Unit of Measure" <> '' then
            SalesLine.Validate("Unit of Measure Code", Entitlement."FOC Unit of Measure");
        SalesLine.Validate(Quantity, Entitlement."FOC Quantity");
        SalesLine.Validate("PTV FOC Item", true);
        SalesLine.Modify(true);

        Entitlement.Status := Entitlement.Status::"FOC Order Created";
        Entitlement."FOC Sales Order No." := SalesHeader."No.";
        Entitlement.Modify(true);

        AppliedEntry.Init();
        AppliedEntry."Entitlement Entry No." := Entitlement."Entry No.";
        AppliedEntry."Scheme Code" := Entitlement."Scheme Code";
        AppliedEntry."Customer No." := Entitlement."Customer No.";
        AppliedEntry."Source Document Type" := AppliedEntry."Source Document Type"::"Target Sales Order";
        AppliedEntry."Document No." := SalesHeader."No.";
        AppliedEntry."Document Line No." := SalesLine."Line No.";
        AppliedEntry."Posting Date" := SalesHeader."Posting Date";
        AppliedEntry."Item No." := Entitlement."FOC Item No.";
        AppliedEntry.Quantity := Entitlement."FOC Quantity";
        AppliedEntry.Insert(true);

        exit(SalesHeader."No.");
    end;

    /// <summary>
    /// Marks a trip/non-monetary entitlement as fulfilled.
    /// </summary>
    procedure MarkTripFulfilled(var Entitlement: Record "PTV Scheme Entitlement")
    var
        NotApprovedErr: Label 'Entitlement %1 must be Approved before marking the trip fulfilled.';
        WrongChoiceErr: Label 'Entitlement %1 has Reward Choice = %2; Trip / Non-Monetary is required.';
    begin
        if Entitlement.Status <> Entitlement.Status::Approved then
            Error(NotApprovedErr, Entitlement."Entry No.");
        if Entitlement."Reward Choice" <> Entitlement."Reward Choice"::"Trip / Non-Monetary" then
            Error(WrongChoiceErr, Entitlement."Entry No.", Entitlement."Reward Choice");

        Entitlement.Status := Entitlement.Status::"Trip Fulfilled";
        Entitlement.Modify(true);
    end;
}
