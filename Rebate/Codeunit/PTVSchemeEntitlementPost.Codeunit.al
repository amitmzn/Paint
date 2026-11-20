codeunit 77204 "PTV Scheme Entitlement Post"
{
    /// <summary>
    /// Posts finalized entitlements to Posted tables and optionally closes the scheme header.
    /// </summary>
    procedure PostEntitlements(SchemeCode: Code[20]; CloseScheme: Boolean): Integer
    var
        SchemeHdr: Record "PTV Scheme Header";
        Entitlement: Record "PTV Scheme Entitlement";
        PostedEnt: Record "PTV Posted Scheme Entitlement";
        Applied: Record "PTV Scheme Applied Entry";
        PostedApplied: Record "PTV Posted Scheme Applied";
        PostedCount: Integer;
        UnsettledSchemeErr: Label 'Scheme %1 still has unsettled entitlements. Settle them or use Archive Settled Entitlements.';
        ClosedErr: Label 'Scheme %1 is already closed.';
        NoneReadyErr: Label 'Scheme %1 has no settled entitlements. Post credit notes or ship the full FOC quantity before archiving.';
    begin
        SchemeHdr.LockTable();
        SchemeHdr.Get(SchemeCode);
        Entitlement.LockTable();
        if SchemeHdr.Status = SchemeHdr.Status::Closed then
            Error(ClosedErr, SchemeCode);

        Entitlement.SetRange("Scheme Code", SchemeCode);
        Entitlement.SetFilter(
            Status, '%1|%2|%3',
            Entitlement.Status::"Credit Note Created",
            Entitlement.Status::"FOC Order Created",
            Entitlement.Status::"Trip Fulfilled");
        if Entitlement.FindSet() then
            repeat
                if IsSettled(Entitlement) then begin
                    PostedEnt.Init();
                    PostedEnt."Original Entry No." := Entitlement."Entry No.";
                    PostedEnt."Scheme Code" := Entitlement."Scheme Code";
                    PostedEnt."Scheme Line No." := Entitlement."Scheme Line No.";
                    PostedEnt."Slab No." := Entitlement."Slab No.";
                    PostedEnt."Qualification Tier Code" := Entitlement."Qualification Tier Code";
                    PostedEnt."FOC Reviewed By" := Entitlement."FOC Reviewed By";
                    PostedEnt."FOC Reviewed On" := Entitlement."FOC Reviewed On";
                    PostedEnt."Customer No." := Entitlement."Customer No.";
                    PostedEnt."Scheme Product Group" := Entitlement."Scheme Product Group";
                    PostedEnt."Period Start Date" := Entitlement."Period Start Date";
                    PostedEnt."Period End Date" := Entitlement."Period End Date";
                    PostedEnt."Eligible Qty (Kg/Ltr)" := Entitlement."Eligible Qty (Kg/Ltr)";
                    PostedEnt."Net Sales Value" := Entitlement."Net Sales Value";
                    PostedEnt."Prior Year Qty" := Entitlement."Prior Year Qty";
                    PostedEnt."Prior Year Value" := Entitlement."Prior Year Value";
                    PostedEnt."Growth %" := Entitlement."Growth %";
                    PostedEnt."Discount Type" := Entitlement."Discount Type";
                    PostedEnt."Reward Choice" := Entitlement."Reward Choice";
                    PostedEnt."Total Rebate Amount" := Entitlement."Total Rebate Amount";
                    PostedEnt."FOC Item No." := Entitlement."FOC Item No.";
                    PostedEnt."FOC Quantity" := Entitlement."FOC Quantity";
                    PostedEnt."Estimated FOC Cost" := Entitlement."Estimated FOC Cost";
                    PostedEnt."Trip Description" := Entitlement."Trip Description";
                    PostedEnt."Credit Memo No." := Entitlement."Credit Memo No.";
                    PostedEnt."FOC Sales Order No." := Entitlement."FOC Sales Order No.";
                    PostedEnt.Status := PostedEnt.Status::Posted;
                    PostedEnt."Posted By" := CopyStr(UserId(), 1, MaxStrLen(PostedEnt."Posted By"));
                    PostedEnt."Posted Date" := CurrentDateTime();
                    PostedEnt.Insert(true);

                    Applied.SetRange("Entitlement Entry No.", Entitlement."Entry No.");
                    if Applied.FindSet() then
                        repeat
                            PostedApplied.Init();
                            PostedApplied."Posted Ent. Entry No." := PostedEnt."Entry No.";
                            PostedApplied."Scheme Code" := Applied."Scheme Code";
                            PostedApplied."Exclusion Group" := Applied."Exclusion Group";
                            PostedApplied."Customer No." := Applied."Customer No.";
                            PostedApplied."Source Document Type" := Applied."Source Document Type";
                            PostedApplied."Document No." := Applied."Document No.";
                            PostedApplied."Document Line No." := Applied."Document Line No.";
                            PostedApplied."Posting Date" := Applied."Posting Date";
                            PostedApplied."Item No." := Applied."Item No.";
                            PostedApplied.Quantity := Applied.Quantity;
                            PostedApplied."Eligible Qty (Kg/Ltr)" := Applied."Eligible Qty (Kg/Ltr)";
                            PostedApplied."Net Amount" := Applied."Net Amount";
                            PostedApplied.Insert(true);
                        until Applied.Next() = 0;
                    Applied.DeleteAll();

                    Entitlement.Delete();
                    PostedCount += 1;
                end;
            until Entitlement.Next() = 0;

        if PostedCount = 0 then begin
            if not CloseScheme then
                Error(NoneReadyErr, SchemeCode);
            PostedEnt.Reset();
            PostedEnt.SetRange("Scheme Code", SchemeCode);
            if PostedEnt.IsEmpty() then
                Error(NoneReadyErr, SchemeCode);
        end;

        if CloseScheme then begin
            Entitlement.SetRange(Status);
            Entitlement.SetFilter(Status, '<>%1', Entitlement.Status::Rejected);
            if not Entitlement.IsEmpty() then
                Error(UnsettledSchemeErr, SchemeCode);
            SchemeHdr.Status := SchemeHdr.Status::Closed;
            SchemeHdr.Modify(true);
        end;

        exit(PostedCount);
    end;

    local procedure IsSettled(var Entitlement: Record "PTV Scheme Entitlement"): Boolean
    var
        CreditMemo: Record "Sales Cr.Memo Header";
        Shipment: Record "Sales Shipment Line";
        CreditLine: Record "Sales Cr.Memo Line";
        ShippedQty: Decimal;
    begin
        case Entitlement.Status of
            Entitlement.Status::"Credit Note Created":
                begin
                    Entitlement.TestField("Credit Memo No.");
                    CreditMemo.SetRange("Pre-Assigned No.", Entitlement."Credit Memo No.");
                    CreditMemo.SetRange("Sell-to Customer No.", Entitlement."Customer No.");
                    if not CreditMemo.FindFirst() then
                        exit(false);
                    CreditLine.SetRange("Document No.", CreditMemo."No.");
                    CreditLine.SetRange(Type, CreditLine.Type::"G/L Account");
                    CreditLine.CalcSums(Amount);
                    if CreditLine.Amount <> Entitlement."Total Rebate Amount" then
                        exit(false);
                    Entitlement."Credit Memo No." := CreditMemo."No.";
                end;
            Entitlement.Status::"FOC Order Created":
                begin
                    Entitlement.TestField("FOC Sales Order No.");
                    Entitlement.TestField("FOC Item No.");
                    Shipment.SetRange("Order No.", Entitlement."FOC Sales Order No.");
                    Shipment.SetRange("Order Line No.", 10000);
                    Shipment.SetRange("Sell-to Customer No.", Entitlement."Customer No.");
                    Shipment.SetRange(Type, Shipment.Type::Item);
                    Shipment.SetRange("No.", Entitlement."FOC Item No.");
                    if Entitlement."FOC Unit of Measure" <> '' then
                        Shipment.SetRange("Unit of Measure Code", Entitlement."FOC Unit of Measure");
                    Shipment.CalcSums(Quantity);
                    ShippedQty := Shipment.Quantity;
                    if ShippedQty < Entitlement."FOC Quantity" then
                        exit(false);
                end;
        end;
        exit(true);
    end;
}
