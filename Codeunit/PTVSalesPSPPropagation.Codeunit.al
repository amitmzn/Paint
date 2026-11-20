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

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", OnAfterValidateEvent, 'Sell-to Customer No.', false, false)]
    local procedure PropagateSalesHeaderCustomer(var Rec: Record "Sales Header"; var xRec: Record "Sales Header"; CurrFieldNo: Integer)
    var
        Customer: Record Customer;
    begin
        if Rec.IsTemporary then
            exit;
        if Rec."Sell-to Customer No." = '' then
            exit;
        if Customer.Get(Rec."Sell-to Customer No.") then begin
            if Customer."Mobile Phone No." <> '' then
                Rec."PTV Mobile No." := Customer."Mobile Phone No."
            else if (Customer."Phone No." <> '') and (Rec."PTV Mobile No." = '') then
                Rec."PTV Mobile No." := Customer."Phone No.";
        end;
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
    var
        UOMMgt: Codeunit "PTV UOM Mgt";
    begin
        CopyPSP(SalesLine, SalesShptLine);
        if SalesShptLine.Type <> SalesShptLine.Type::Item then
            exit;
        if SalesShptLine."Quantity (Base)" = 0 then
            exit;
        if SalesShptLine."PTV Litres per Base Unit" <= 0 then
            SalesShptLine."PTV Litres per Base Unit" := UOMMgt.PostingLitresPerBaseUnit(SalesShptLine."No.");
        UOMMgt.CheckPostingLitreUOM(SalesShptLine."No.", SalesShptLine."Unit of Measure Code", SalesShptLine."Qty. per Unit of Measure", SalesShptLine."PTV Litres per Base Unit");
        SalesShptLine."PTV Quantity Litres" := SalesShptLine."Quantity (Base)" * SalesShptLine."PTV Litres per Base Unit";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnBeforeSalesInvLineInsert, '', false, false)]
    local procedure CopyToInvoice(var SalesInvLine: Record "Sales Invoice Line"; SalesInvHeader: Record "Sales Invoice Header"; SalesLine: Record "Sales Line"; CommitIsSuppressed: Boolean; var IsHandled: Boolean; PostingSalesLine: Record "Sales Line"; SalesShipmentHeader: Record "Sales Shipment Header"; SalesHeader: Record "Sales Header"; var ReturnReceiptHeader: Record "Return Receipt Header")
    var
        UOMMgt: Codeunit "PTV UOM Mgt";
        ShipmentLine: Record "Sales Shipment Line";
    begin
        CopyPSP(SalesLine, SalesInvLine);
        if SalesInvLine.Type <> SalesInvLine.Type::Item then
            exit;
        if SalesInvLine."Quantity (Base)" = 0 then
            exit;
        if SalesInvLine."Shipment No." <> '' then
            if ShipmentLine.Get(SalesInvLine."Shipment No.", SalesInvLine."Shipment Line No.") then
                if ShipmentLine."No." = SalesInvLine."No." then
                    SalesInvLine."PTV Litres per Base Unit" := ShipmentLine."PTV Litres per Base Unit";
        if SalesInvLine."PTV Litres per Base Unit" <= 0 then
            SalesInvLine."PTV Litres per Base Unit" := UOMMgt.PostingLitresPerBaseUnit(SalesInvLine."No.");
        UOMMgt.CheckPostingLitreUOM(SalesInvLine."No.", SalesInvLine."Unit of Measure Code", SalesInvLine."Qty. per Unit of Measure", SalesInvLine."PTV Litres per Base Unit");
        SalesInvLine."PTV Quantity Litres" := SalesInvLine."Quantity (Base)" * SalesInvLine."PTV Litres per Base Unit";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnBeforeSalesCrMemoLineInsert, '', false, false)]
    local procedure CopyToCrMemo(var SalesCrMemoLine: Record "Sales Cr.Memo Line"; SalesCrMemoHeader: Record "Sales Cr.Memo Header"; SalesLine: Record "Sales Line"; CommitIsSuppressed: Boolean; var IsHandled: Boolean; var SalesHeader: Record "Sales Header"; var SalesShptHeader: Record "Sales Shipment Header"; var ReturnRcptHeader: Record "Return Receipt Header"; var PostingSalesLine: Record "Sales Line")
    var
        AppliedEntry: Record "Item Ledger Entry";
        UOMMgt: Codeunit "PTV UOM Mgt";
    begin
        CopyPSP(SalesLine, SalesCrMemoLine);
        if SalesCrMemoLine.Type <> SalesCrMemoLine.Type::Item then
            exit;
        if SalesCrMemoLine."Quantity (Base)" = 0 then
            exit;
        if SalesLine."Appl.-from Item Entry" <> 0 then
            if AppliedEntry.Get(SalesLine."Appl.-from Item Entry") then
                if AppliedEntry."Item No." = SalesCrMemoLine."No." then
                    SalesCrMemoLine."PTV Litres per Base Unit" := AppliedEntry."PTV Litres per Base Unit";
        if SalesCrMemoLine."PTV Litres per Base Unit" <= 0 then
            SalesCrMemoLine."PTV Litres per Base Unit" := UOMMgt.PostingLitresPerBaseUnit(SalesCrMemoLine."No.");
        UOMMgt.CheckPostingLitreUOM(SalesCrMemoLine."No.", SalesCrMemoLine."Unit of Measure Code", SalesCrMemoLine."Qty. per Unit of Measure", SalesCrMemoLine."PTV Litres per Base Unit");
        SalesCrMemoLine."PTV Quantity Litres" := SalesCrMemoLine."Quantity (Base)" * SalesCrMemoLine."PTV Litres per Base Unit";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnBeforeSalesInvHeaderInsert, '', false, false)]
    local procedure CopyHeaderToInvoice(var SalesInvHeader: Record "Sales Invoice Header"; var SalesHeader: Record "Sales Header"; CommitIsSuppressed: Boolean; var IsHandled: Boolean; WhseShip: Boolean; WhseShptHeader: Record "Warehouse Shipment Header"; InvtPickPutaway: Boolean)
    begin
        if SalesHeader."PTV Fast Sales" then begin
            SalesInvHeader."PTV Fast Sales" := true;
            SalesInvHeader."PTV Customer Type" := SalesHeader."PTV Customer Type";
        end;
        if SalesHeader."PTV Mobile No." <> '' then
            SalesInvHeader."PTV Mobile No." := SalesHeader."PTV Mobile No.";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnBeforeSalesShptHeaderInsert, '', false, false)]
    local procedure CopyHeaderToShipment(var SalesShptHeader: Record "Sales Shipment Header"; SalesHeader: Record "Sales Header"; CommitIsSuppressed: Boolean; var IsHandled: Boolean; var TempWhseRcptHeader: Record "Warehouse Receipt Header" temporary; WhseReceive: Boolean; var TempWhseShptHeader: Record "Warehouse Shipment Header" temporary; WhseShip: Boolean; InvtPickPutaway: Boolean)
    begin
        if SalesHeader."PTV Fast Sales" then begin
            SalesShptHeader."PTV Fast Sales" := true;
            SalesShptHeader."PTV Customer Type" := SalesHeader."PTV Customer Type";
        end;
        if SalesHeader."PTV Mobile No." <> '' then
            SalesShptHeader."PTV Mobile No." := SalesHeader."PTV Mobile No.";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnBeforeSalesCrMemoHeaderInsert, '', false, false)]
    local procedure CopyHeaderToCrMemo(var SalesCrMemoHeader: Record "Sales Cr.Memo Header"; var SalesHeader: Record "Sales Header"; CommitIsSuppressed: Boolean; var IsHandled: Boolean; var SalesInvHeader: Record "Sales Invoice Header")
    begin
        if SalesHeader."PTV Fast Sales" then begin
            SalesCrMemoHeader."PTV Fast Sales" := true;
            SalesCrMemoHeader."PTV Customer Type" := SalesHeader."PTV Customer Type";
        end;
        if SalesHeader."PTV Mobile No." <> '' then
            SalesCrMemoHeader."PTV Mobile No." := SalesHeader."PTV Mobile No.";
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
