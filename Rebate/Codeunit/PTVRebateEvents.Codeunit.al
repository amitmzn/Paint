codeunit 77200 "PTV Rebate Events"
{
    [EventSubscriber(ObjectType::Table, Database::"Sales Line", OnAfterValidateEvent, 'No.', false, false)]
    local procedure SetSalesLineCustomerTieUp(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; CurrFieldNo: Integer)
    var
        Customer: Record Customer;
    begin
        if Rec.IsTemporary then
            exit;
        if Rec.Type <> Rec.Type::Item then
            exit;
        Customer.SetLoadFields("PTV Tie-Up Discount Opted");
        if Customer.Get(Rec."Sell-to Customer No.") then
            Rec."PTV Tie-Up Discount" := Customer."PTV Tie-Up Discount Opted";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", OnAfterValidateEvent, 'Unit Price', false, false)]
    local procedure DetectSpecialPriceOnUnitPrice(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; CurrFieldNo: Integer)
    var
        Item: Record Item;
        RebateSetup: Record "PTV Rebate Setup";
    begin
        if Rec.IsTemporary then
            exit;
        if CurrFieldNo <> Rec.FieldNo("Unit Price") then
            exit;
        if Rec.Type <> Rec.Type::Item then
            exit;
        RebateSetup.SetLoadFields("Auto Detect Special Price");
        RebateSetup.GetSetup();
        if not RebateSetup."Auto Detect Special Price" then
            exit;
        Item.SetLoadFields("Unit Price");
        if Item.Get(Rec."No.") then
            if (Item."Unit Price" > 0) and (Rec."Unit Price" < Item."Unit Price") and not Rec."PTV FOC Item" then
                Rec."PTV Special Price" := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", OnAfterValidateEvent, 'PTV FOC Item', false, false)]
    local procedure ZeroUnitPriceOnFOCItem(var Rec: Record "Sales Line"; var xRec: Record "Sales Line"; CurrFieldNo: Integer)
    begin
        if Rec.IsTemporary then
            exit;
        if Rec."PTV FOC Item" and (Rec."Unit Price" <> 0) then
            Rec.Validate("Unit Price", 0);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnBeforeSalesInvLineInsert, '', false, false)]
    local procedure CopyRebateFlagsToInvLine(var SalesInvLine: Record "Sales Invoice Line"; SalesInvHeader: Record "Sales Invoice Header"; SalesLine: Record "Sales Line"; CommitIsSuppressed: Boolean; var IsHandled: Boolean; PostingSalesLine: Record "Sales Line"; SalesShipmentHeader: Record "Sales Shipment Header"; SalesHeader: Record "Sales Header"; var ReturnReceiptHeader: Record "Return Receipt Header")
    begin
        SalesInvLine."PTV FOC Item" := SalesLine."PTV FOC Item";
        SalesInvLine."PTV Special Price" := SalesLine."PTV Special Price";
        SalesInvLine."PTV Tie-Up Discount" := SalesLine."PTV Tie-Up Discount";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnBeforeSalesCrMemoLineInsert, '', false, false)]
    local procedure CopyRebateFlagsToCrMemoLine(var SalesCrMemoLine: Record "Sales Cr.Memo Line"; SalesCrMemoHeader: Record "Sales Cr.Memo Header"; SalesLine: Record "Sales Line"; CommitIsSuppressed: Boolean; var IsHandled: Boolean; var SalesHeader: Record "Sales Header"; var SalesShptHeader: Record "Sales Shipment Header"; var ReturnRcptHeader: Record "Return Receipt Header"; var PostingSalesLine: Record "Sales Line")
    begin
        SalesCrMemoLine."PTV FOC Item" := SalesLine."PTV FOC Item";
        SalesCrMemoLine."PTV Special Price" := SalesLine."PTV Special Price";
        SalesCrMemoLine."PTV Tie-Up Discount" := SalesLine."PTV Tie-Up Discount";
    end;
}
