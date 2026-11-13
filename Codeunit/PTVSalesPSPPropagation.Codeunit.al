codeunit 76212 "PTV Sales PSP Propagation"
{
    [EventSubscriber(ObjectType::Table, Database::"Sales Line", OnAfterValidateEvent, 'No.', false, false)]
    local procedure PropagateSalesLine(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; CurrFieldNo: Integer)
    var
        SalesHeader: Record "Sales Header";
    begin
        if Rec.IsTemporary then
            exit;
        CopyFromItem(Rec);
        if Rec."PTV Promised Delivery Date" = 0D then
            if SalesHeader.Get(Rec."Document Type", Rec."Document No.") then
                Rec."PTV Promised Delivery Date" := SalesHeader."PTV Promised Delivery Date";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", OnAfterValidateEvent, 'No.', false, false)]
    local procedure PropagatePurchaseLine(var Rec: Record "Purchase Line"; var xRec: Record "Purchase Line"; CurrFieldNo: Integer)
    var
        Item: Record Item;
        PaintSetup: Record "PTV Paint Setup";
    begin
        if Rec.IsTemporary then
            exit;
        if Rec.Type <> Rec.Type::Item then
            exit;
        PaintSetup.SetLoadFields("Propagate PSP");
        PaintSetup.GetSetup();
        if not PaintSetup."Propagate PSP" then
            exit;
        Item.SetLoadFields("PTV Product Code", "PTV Shade Code", "PTV Pack Code");
        if not Item.Get(Rec."No.") then
            exit;
        Rec."PTV Product Code" := Item."PTV Product Code";
        Rec."PTV Shade Code" := Item."PTV Shade Code";
        Rec."PTV Pack Code" := Item."PTV Pack Code";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnBeforeSalesShptLineInsert, '', false, false)]
    local procedure CopyToShipment(var SalesShptLine: Record "Sales Shipment Line"; SalesShptHeader: Record "Sales Shipment Header"; SalesLine: Record "Sales Line"; CommitIsSuppressed: Boolean; PostedWhseShipmentLine: Record "Posted Whse. Shipment Line"; SalesHeader: Record "Sales Header"; WhseShip: Boolean; WhseReceive: Boolean; ItemLedgShptEntryNo: Integer; xSalesLine: Record "Sales Line"; var TempSalesLineGlobal: Record "Sales Line" temporary; var IsHandled: Boolean)
    begin
        CopyPSP(SalesLine, SalesShptLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnBeforeSalesInvLineInsert, '', false, false)]
    local procedure CopyToInvoice(var SalesInvLine: Record "Sales Invoice Line"; SalesInvHeader: Record "Sales Invoice Header"; SalesLine: Record "Sales Line"; CommitIsSuppressed: Boolean; var IsHandled: Boolean; PostingSalesLine: Record "Sales Line"; SalesShipmentHeader: Record "Sales Shipment Header"; SalesHeader: Record "Sales Header"; var ReturnReceiptHeader: Record "Return Receipt Header")
    begin
        CopyPSP(SalesLine, SalesInvLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnBeforeSalesCrMemoLineInsert, '', false, false)]
    local procedure CopyToCrMemo(var SalesCrMemoLine: Record "Sales Cr.Memo Line"; SalesCrMemoHeader: Record "Sales Cr.Memo Header"; SalesLine: Record "Sales Line"; CommitIsSuppressed: Boolean; var IsHandled: Boolean; var SalesHeader: Record "Sales Header"; var SalesShptHeader: Record "Sales Shipment Header"; var ReturnRcptHeader: Record "Return Receipt Header"; var PostingSalesLine: Record "Sales Line")
    begin
        CopyPSP(SalesLine, SalesCrMemoLine);
    end;

    local procedure CopyFromItem(var SalesLine: Record "Sales Line")
    var
        Item: Record Item;
        PaintSetup: Record "PTV Paint Setup";
    begin
        if SalesLine.Type <> SalesLine.Type::Item then
            exit;
        PaintSetup.SetLoadFields("Propagate PSP");
        PaintSetup.GetSetup();
        if not PaintSetup."Propagate PSP" then
            exit;
        Item.SetLoadFields("PTV Product Code", "PTV Shade Code", "PTV Pack Code");
        if not Item.Get(SalesLine."No.") then
            exit;
        SalesLine."PTV Product Code" := Item."PTV Product Code";
        SalesLine."PTV Shade Code" := Item."PTV Shade Code";
        SalesLine."PTV Pack Code" := Item."PTV Pack Code";
    end;

    local procedure CopyPSP(SalesLine: Record "Sales Line"; var PostedLine: Record "Sales Shipment Line")
    begin
        PostedLine."PTV Product Code" := SalesLine."PTV Product Code";
        PostedLine."PTV Shade Code" := SalesLine."PTV Shade Code";
        PostedLine."PTV Pack Code" := SalesLine."PTV Pack Code";
        PostedLine."PTV Promised Delivery Date" := SalesLine."PTV Promised Delivery Date";
    end;

    local procedure CopyPSP(SalesLine: Record "Sales Line"; var PostedLine: Record "Sales Invoice Line")
    begin
        PostedLine."PTV Product Code" := SalesLine."PTV Product Code";
        PostedLine."PTV Shade Code" := SalesLine."PTV Shade Code";
        PostedLine."PTV Pack Code" := SalesLine."PTV Pack Code";
        PostedLine."PTV Promised Delivery Date" := SalesLine."PTV Promised Delivery Date";
    end;

    local procedure CopyPSP(SalesLine: Record "Sales Line"; var PostedLine: Record "Sales Cr.Memo Line")
    begin
        PostedLine."PTV Product Code" := SalesLine."PTV Product Code";
        PostedLine."PTV Shade Code" := SalesLine."PTV Shade Code";
        PostedLine."PTV Pack Code" := SalesLine."PTV Pack Code";
        PostedLine."PTV Promised Delivery Date" := SalesLine."PTV Promised Delivery Date";
    end;
}
