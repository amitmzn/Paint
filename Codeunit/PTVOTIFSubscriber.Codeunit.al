codeunit 76213 "PTV OTIF Subscriber"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnBeforeSalesShptLineInsert, '', false, false)]
    local procedure SetOnTimeInFull(var SalesShptLine: Record "Sales Shipment Line"; SalesShptHeader: Record "Sales Shipment Header"; SalesLine: Record "Sales Line"; CommitIsSuppressed: Boolean; PostedWhseShipmentLine: Record "Posted Whse. Shipment Line"; SalesHeader: Record "Sales Header"; WhseShip: Boolean; WhseReceive: Boolean; ItemLedgShptEntryNo: Integer; xSalesLine: Record "Sales Line"; var TempSalesLineGlobal: Record "Sales Line" temporary; var IsHandled: Boolean)
    var
        PromisedDate: Date;
    begin
        PromisedDate := SalesLine."PTV Promised Delivery Date";
        if PromisedDate = 0D then
            PromisedDate := SalesHeader."PTV Promised Delivery Date";
        SalesShptLine."PTV On Time" := (PromisedDate = 0D) or (SalesShptHeader."Posting Date" <= PromisedDate);
        SalesShptLine."PTV In Full" := SalesLine."Outstanding Quantity" <= SalesLine."Qty. to Ship";
    end;
}
