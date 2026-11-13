codeunit 76211 "PTV QC Invoice Gate"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", OnBeforePostPurchaseDoc, '', false, false)]
    local procedure EnforceQCBeforeInvoice(var PurchaseHeader: Record "Purchase Header"; PreviewMode: Boolean; CommitIsSupressed: Boolean; var HideProgressWindow: Boolean; var ItemJnlPostLine: Codeunit "Item Jnl.-Post Line"; var IsHandled: Boolean)
    begin
        if PurchaseHeader."Document Type" <> PurchaseHeader."Document Type"::Invoice then
            if PurchaseHeader."Document Type" <> PurchaseHeader."Document Type"::Order then
                exit;
        CheckInvoiceAllowed(PurchaseHeader);
    end;

    local procedure CheckInvoiceAllowed(PurchaseHeader: Record "Purchase Header")
    var
        PaintSetup: Record "PTV Paint Setup";
        PurchLine: Record "Purchase Line";
        Item: Record Item;
        QltyInspectionHeader: Record "Qlty. Inspection Header";
        SumPassQty: Decimal;
        FailPending: Boolean;
        InspectionNo: Code[20];
        ResultText: Text;
        InvoiceBlockedErr: Label 'Quantity to invoice exceeds the quantity accepted by quality inspection. Finish inspection %1 (currently %2) or complete the rework decision.', Comment = '%1 = inspection no., %2 = result';
    begin
        PaintSetup.SetLoadFields("QC Gate On Invoice Posting");
        PaintSetup.GetSetup();
        if not PaintSetup."QC Gate On Invoice Posting" then
            exit;

        PurchLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchLine.SetRange(Type, PurchLine.Type::Item);
        PurchLine.SetFilter("Qty. to Invoice", '>0');
        PurchLine.SetLoadFields("No.", "Qty. to Invoice", "Receipt No.", "Receipt Line No.");
        if not PurchLine.FindSet() then
            exit;
        repeat
            Item.SetLoadFields("PTV QC Enabled");
            if Item.Get(PurchLine."No.") and Item."PTV QC Enabled" then begin
                SumPassQty := 0;
                FailPending := false;
                InspectionNo := '';
                ResultText := '';
                QltyInspectionHeader.SetRange("Source Table No.", Database::"Purch. Rcpt. Header");
                QltyInspectionHeader.SetRange("Source Document No.", PurchLine."Receipt No.");
                QltyInspectionHeader.SetRange("Source Document Line No.", PurchLine."Receipt Line No.");
                QltyInspectionHeader.SetRange("Source Item No.", PurchLine."No.");
                QltyInspectionHeader.SetLoadFields("No.", Status, "Result Code", "Pass Quantity", "Fail Quantity");
                if QltyInspectionHeader.FindSet() then
                    repeat
                        InspectionNo := QltyInspectionHeader."No.";
                        ResultText := QltyInspectionHeader."Result Code";
                        if (QltyInspectionHeader.Status = QltyInspectionHeader.Status::Finished) and (QltyInspectionHeader."Result Code" = 'PASS') then
                            SumPassQty += QltyInspectionHeader."Pass Quantity";
                        if QltyInspectionHeader."Fail Quantity" > 0 then
                            if not ((QltyInspectionHeader.Status = QltyInspectionHeader.Status::Finished) and (QltyInspectionHeader."Result Code" = 'PASS')) then
                                FailPending := true;
                    until QltyInspectionHeader.Next() = 0;
                if FailPending or (PurchLine."Qty. to Invoice" > SumPassQty) then
                    Error(ErrorInfo.Create(StrSubstNo(InvoiceBlockedErr, InspectionNo, ResultText)));
            end;
        until PurchLine.Next() = 0;
    end;
}
