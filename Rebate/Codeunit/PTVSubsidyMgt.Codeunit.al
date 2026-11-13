codeunit 77206 "PTV Subsidy Mgt"
{
    /// <summary>
    /// Releases a subsidy header after validating required dates.
    /// </summary>
    procedure ReleaseSubsidy(var SubsidyHdr: Record "PTV Subsidy Header")
    var
        MissingDatesErr: Label 'Start Date and End Date must be set before releasing Subsidy %1.';
        ClosedErr: Label 'Closed subsidy %1 cannot be released.';
    begin
        if SubsidyHdr.Status = SubsidyHdr.Status::Closed then
            Error(ClosedErr, SubsidyHdr.Code);
        if (SubsidyHdr."Start Date" = 0D) or (SubsidyHdr."End Date" = 0D) or (SubsidyHdr."Start Date" > SubsidyHdr."End Date") then
            Error(MissingDatesErr, SubsidyHdr.Code);

        SubsidyHdr.Status := SubsidyHdr.Status::Released;
        SubsidyHdr.Modify(true);
    end;

    /// <summary>
    /// Reopens a released subsidy header.
    /// </summary>
    procedure ReopenSubsidy(var SubsidyHdr: Record "PTV Subsidy Header")
    var
        ClosedErr: Label 'Closed subsidy %1 cannot be reopened.';
    begin
        if SubsidyHdr.Status = SubsidyHdr.Status::Closed then
            Error(ClosedErr, SubsidyHdr.Code);

        SubsidyHdr.Status := SubsidyHdr.Status::Open;
        SubsidyHdr.Modify(true);
    end;

    /// <summary>
    /// Evaluates sales qualification and entitled subsidy amounts across open lines of a subsidy header.
    /// </summary>
    procedure CalculateEntitlements(var SubsidyHdr: Record "PTV Subsidy Header")
    var
        SubLine: Record "PTV Subsidy Line";
        Customer: Record Customer;
        GrowthPayGate: Codeunit "PTV Scheme Growth & Pay Gate";
        SalesValue: Decimal;
        SalesQty: Decimal;
        Qualified: Boolean;
        NotReleasedErr: Label 'Subsidy %1 must be Released before calculating entitlements.';
        MissingDatesErr: Label 'Start Date and End Date must be set on Subsidy %1.';
    begin
        if SubsidyHdr.Status <> SubsidyHdr.Status::Released then
            Error(NotReleasedErr, SubsidyHdr.Code);
        if (SubsidyHdr."Start Date" = 0D) or (SubsidyHdr."End Date" = 0D) then
            Error(MissingDatesErr, SubsidyHdr.Code);

        SubLine.SetRange("Subsidy Code", SubsidyHdr.Code);
        if not SubLine.FindSet(true) then
            exit;

        Customer.SetLoadFields("Territory Code");
        repeat
            if SubLine.Status in [SubLine.Status::Open, SubLine.Status::"Pending Approval"] then begin
                SalesValue := 0;
                SalesQty := 0;
                Qualified := false;

                if (SubLine."Customer No." <> '') and Customer.Get(SubLine."Customer No.") and
                   GrowthPayGate.MatchesTextFilter(Customer."Territory Code", SubsidyHdr."Territory Filter")
                then begin
                    CalcCustomerSales(
                        SubLine."Customer No.",
                        SubsidyHdr."Start Date",
                        SubsidyHdr."End Date",
                        SubsidyHdr."Location Filter",
                        SubLine."Condition Type" = SubLine."Condition Type"::"Gross Sales",
                        SalesValue,
                        SalesQty);
                    Qualified := IsLineQualified(SubLine, SalesValue, SalesQty);
                end;

                SubLine."Actual Sales Value" := Round(SalesValue, 0.01);
                SubLine."Actual Sales Qty (Kg/Ltr)" := Round(SalesQty, 0.01);
                SubLine."Sales Qualified" := Qualified;
                if Qualified then
                    SubLine."Entitled Amount" := SubLine."Subsidy Amount"
                else
                    SubLine."Entitled Amount" := 0;
                SubLine.Modify(true);
            end;
        until SubLine.Next() = 0;
    end;

    /// <summary>
    /// Marks all qualified open subsidy lines with positive entitled amount as Approved.
    /// </summary>
    procedure ApproveQualifiedLines(SubsidyCode: Code[20]): Integer
    var
        SubsidyHdr: Record "PTV Subsidy Header";
        SubLine: Record "PTV Subsidy Line";
        ApprovedCount: Integer;
        ClosedErr: Label 'Closed subsidy %1 cannot be modified.';
    begin
        SubsidyHdr.Get(SubsidyCode);
        if SubsidyHdr.Status = SubsidyHdr.Status::Closed then
            Error(ClosedErr, SubsidyCode);

        SubLine.SetRange("Subsidy Code", SubsidyCode);
        SubLine.SetRange("Sales Qualified", true);
        SubLine.SetFilter(Status, '%1|%2', SubLine.Status::Open, SubLine.Status::"Pending Approval");
        SubLine.SetFilter("Entitled Amount", '>0');
        if SubLine.FindSet(true) then
            repeat
                SubLine.Status := SubLine.Status::Approved;
                SubLine.Modify(true);
                ApprovedCount += 1;
            until SubLine.Next() = 0;

        exit(ApprovedCount);
    end;

    /// <summary>
    /// Creates Sales Credit Memos and writes Subsidy Ledger Entries for approved subsidy lines.
    /// </summary>
    procedure CreateCreditMemos(SubsidyCode: Code[20]): Integer
    var
        SubsidyHdr: Record "PTV Subsidy Header";
        SubLine: Record "PTV Subsidy Line";
        RebateSetup: Record "PTV Rebate Setup";
        GLAccountNo: Code[20];
        CreatedCount: Integer;
        MissingGLErr: Label 'Configure Subsidy G/L Account on Subsidy %1 or Default Rebate G/L Account in Rebate & Scheme Setup.';
        ClosedErr: Label 'Closed subsidy %1 cannot issue credit memos.';
    begin
        SubsidyHdr.Get(SubsidyCode);
        if SubsidyHdr.Status = SubsidyHdr.Status::Closed then
            Error(ClosedErr, SubsidyCode);

        RebateSetup.GetSetup();
        GLAccountNo := SubsidyHdr."Rebate G/L Account";
        if GLAccountNo = '' then
            GLAccountNo := RebateSetup."Default Rebate G/L Account";
        if GLAccountNo = '' then
            Error(MissingGLErr, SubsidyCode);

        SubLine.SetRange("Subsidy Code", SubsidyCode);
        SubLine.SetRange(Status, SubLine.Status::Approved);
        SubLine.SetRange("Credit Memo No.", '');
        SubLine.SetFilter("Entitled Amount", '>0');
        if SubLine.FindSet(true) then
            repeat
                CreateSingleCreditMemo(SubsidyHdr, SubLine, RebateSetup, GLAccountNo);
                CreatedCount += 1;
            until SubLine.Next() = 0;

        exit(CreatedCount);
    end;

    /// <summary>
    /// Marks credit-note-created lines as Posted and closes the subsidy header.
    /// </summary>
    procedure CloseSubsidy(var SubsidyHdr: Record "PTV Subsidy Header")
    var
        SubLine: Record "PTV Subsidy Line";
        AlreadyClosedErr: Label 'Subsidy %1 is already closed.';
    begin
        if SubsidyHdr.Status = SubsidyHdr.Status::Closed then
            Error(AlreadyClosedErr, SubsidyHdr.Code);

        SubLine.SetRange("Subsidy Code", SubsidyHdr.Code);
        SubLine.SetRange(Status, SubLine.Status::"Credit Note Created");
        if SubLine.FindSet(true) then
            repeat
                SubLine.Status := SubLine.Status::Posted;
                SubLine.Modify(true);
            until SubLine.Next() = 0;

        SubsidyHdr.Status := SubsidyHdr.Status::Closed;
        SubsidyHdr.Modify(true);
    end;

    local procedure CalcCustomerSales(CustomerNo: Code[20]; StartDate: Date; EndDate: Date; LocationFilter: Text[100]; IncludeVAT: Boolean; var SalesValue: Decimal; var SalesQty: Decimal)
    var
        SalesInvLine: Record "Sales Invoice Line";
        SalesCrLine: Record "Sales Cr.Memo Line";
        GrowthPayGate: Codeunit "PTV Scheme Growth & Pay Gate";
        UOMMgt: Codeunit "PTV UOM Mgt";
        LineLitres: Decimal;
        LineSG: Decimal;
    begin
        SalesInvLine.SetCurrentKey("Sell-to Customer No.", "Posting Date", Type);
        SalesInvLine.SetRange("Sell-to Customer No.", CustomerNo);
        SalesInvLine.SetRange("Posting Date", StartDate, EndDate);
        SalesInvLine.SetRange(Type, SalesInvLine.Type::Item);
        SalesInvLine.SetLoadFields(
            "No.", "Unit of Measure Code", "Location Code", Quantity, Amount, "Amount Including VAT");
        if SalesInvLine.FindSet() then
            repeat
                if GrowthPayGate.MatchesTextFilter(SalesInvLine."Location Code", LocationFilter) then begin
                    if IncludeVAT then
                        SalesValue += SalesInvLine."Amount Including VAT"
                    else
                        SalesValue += SalesInvLine.Amount;

                    LineLitres := UOMMgt.LineQuantityToLitres(SalesInvLine."No.", SalesInvLine."Unit of Measure Code", SalesInvLine.Quantity);
                    LineSG := UOMMgt.GetSpecificGravity(SalesInvLine."No.");
                    if LineSG > 0 then
                        SalesQty += UOMMgt.WeightFromVolume(LineLitres, LineSG)
                    else
                        SalesQty += LineLitres;
                end;
            until SalesInvLine.Next() = 0;

        SalesCrLine.SetCurrentKey("Sell-to Customer No.", "Posting Date", Type);
        SalesCrLine.SetRange("Sell-to Customer No.", CustomerNo);
        SalesCrLine.SetRange("Posting Date", StartDate, EndDate);
        SalesCrLine.SetRange(Type, SalesCrLine.Type::Item);
        SalesCrLine.SetLoadFields(
            "No.", "Unit of Measure Code", "Location Code", Quantity, Amount, "Amount Including VAT");
        if SalesCrLine.FindSet() then
            repeat
                if GrowthPayGate.MatchesTextFilter(SalesCrLine."Location Code", LocationFilter) then begin
                    if IncludeVAT then
                        SalesValue -= SalesCrLine."Amount Including VAT"
                    else
                        SalesValue -= SalesCrLine.Amount;

                    LineLitres := UOMMgt.LineQuantityToLitres(SalesCrLine."No.", SalesCrLine."Unit of Measure Code", SalesCrLine.Quantity);
                    LineSG := UOMMgt.GetSpecificGravity(SalesCrLine."No.");
                    if LineSG > 0 then
                        SalesQty -= UOMMgt.WeightFromVolume(LineLitres, LineSG)
                    else
                        SalesQty -= LineLitres;
                end;
            until SalesCrLine.Next() = 0;
    end;

    local procedure IsLineQualified(SubLine: Record "PTV Subsidy Line"; SalesValue: Decimal; SalesQty: Decimal): Boolean
    begin
        case SubLine."Condition Type" of
            SubLine."Condition Type"::"No Condition":
                exit(true);
            SubLine."Condition Type"::"Gross Sales",
            SubLine."Condition Type"::"Net Sales":
                exit(SalesValue >= SubLine."Minimum Value");
            SubLine."Condition Type"::Quantity:
                exit(SalesQty >= SubLine."Minimum Value");
        end;
        exit(false);
    end;

    local procedure CreateSingleCreditMemo(SubsidyHdr: Record "PTV Subsidy Header"; var SubLine: Record "PTV Subsidy Line"; RebateSetup: Record "PTV Rebate Setup"; GLAccountNo: Code[20])
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        LedgerEntry: Record "PTV Subsidy Ledger Entry";
        LineDesc: Text;
    begin
        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::"Credit Memo";
        SalesHeader."No." := '';
        SalesHeader.Insert(true);
        SalesHeader.Validate("Sell-to Customer No.", SubLine."Customer No.");
        SalesHeader.Validate("Posting Date", WorkDate());
        if RebateSetup."Posted Credit Memo Nos." <> '' then
            SalesHeader.Validate("Posting No. Series", RebateSetup."Posted Credit Memo Nos.");
        SalesHeader."External Document No." := CopyStr(SubsidyHdr.Code, 1, MaxStrLen(SalesHeader."External Document No."));
        SalesHeader."Posting Description" := CopyStr(
            StrSubstNo('%1 (%2..%3)', SubsidyHdr.Description, SubsidyHdr."Start Date", SubsidyHdr."End Date"),
            1, MaxStrLen(SalesHeader."Posting Description"));
        SalesHeader.Modify(true);

        SalesLine.Init();
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Line No." := 10000;
        SalesLine.Insert(true);
        SalesLine.Validate(Type, SalesLine.Type::"G/L Account");
        SalesLine.Validate("No.", GLAccountNo);
        SalesLine.Validate(Quantity, 1);
        SalesLine.Validate("Unit Price", SubLine."Entitled Amount");
        if SubLine."Beneficiary Name" <> '' then
            LineDesc := StrSubstNo('%1 - %2 (%3)', SubsidyHdr.Code, SubLine."Subsidy Type", SubLine."Beneficiary Name")
        else
            LineDesc := StrSubstNo('%1 - %2', SubsidyHdr.Code, SubLine."Subsidy Type");
        SalesLine.Description := CopyStr(LineDesc, 1, MaxStrLen(SalesLine.Description));
        if RebateSetup."Suppress VAT on Credit Notes" then begin
            SalesLine.Validate("VAT Bus. Posting Group", '');
            SalesLine.Validate("VAT Prod. Posting Group", '');
        end;
        SalesLine.Modify(true);

        SubLine."Credit Memo No." := SalesHeader."No.";
        SubLine.Status := SubLine.Status::"Credit Note Created";
        SubLine.Modify(true);

        LedgerEntry.Init();
        LedgerEntry."Subsidy Code" := SubsidyHdr.Code;
        LedgerEntry."Customer No." := SubLine."Customer No.";
        LedgerEntry."Subsidy Type" := SubLine."Subsidy Type";
        LedgerEntry."Beneficiary Name" := SubLine."Beneficiary Name";
        LedgerEntry."Posting Date" := SalesHeader."Posting Date";
        LedgerEntry.Amount := SubLine."Entitled Amount";
        LedgerEntry."Credit Memo No." := SalesHeader."No.";
        LedgerEntry.Insert(true);
    end;
}
