codeunit 77200 "PTV Rebate Events"
{
    Permissions = tabledata "PTV Scheme Entitlement" = r,
                  tabledata "PTV Posted Scheme Entitlement" = r,
                  tabledata "PTV Scheme Header" = r,
                  tabledata "PTV Rebate Setup" = rim;

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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnBeforePostSalesDoc, '', false, false)]
    local procedure VerifySchemeSettlementDocument(var SalesHeader: Record "Sales Header"; CommitIsSuppressed: Boolean; PreviewMode: Boolean; var HideProgressWindow: Boolean; var IsHandled: Boolean; var CalledBy: Integer)
    var
        Entitlement: Record "PTV Scheme Entitlement";
        Header: Record "PTV Scheme Header";
        Setup: Record "PTV Rebate Setup";
        Line: Record "Sales Line";
        ExtraLine: Record "Sales Line";
        RequireZeroVAT: Boolean;
        InvalidRewardErr: Label 'Line %1 on scheme order %2 no longer matches the approved free-of-charge reward.';
        InvalidCreditErr: Label 'Scheme credit memo %1 no longer matches the approved credit amount.';
        ZeroVATErr: Label 'Scheme document %1 requires the configured zero VAT posting groups on line %2.';
    begin
        if SalesHeader."PTV Scheme Entitlement Entry" = 0 then
            exit;
        if not Entitlement.Get(SalesHeader."PTV Scheme Entitlement Entry") then begin
            VerifyArchivedFOCOrder(SalesHeader);
            exit;
        end;
        case SalesHeader."Document Type" of
            SalesHeader."Document Type"::Order:
                begin
                    Entitlement.TestField(Status, Entitlement.Status::"FOC Order Created");
                    Entitlement.TestField("FOC Sales Order No.", SalesHeader."No.");
                end;
            SalesHeader."Document Type"::"Credit Memo":
                begin
                    Entitlement.TestField(Status, Entitlement.Status::"Credit Note Created");
                    Entitlement.TestField("Credit Memo No.", SalesHeader."No.");
                end;
            else
                exit;
        end;
        SalesHeader.TestField("Sell-to Customer No.", Entitlement."Customer No.");

        Header.Get(Entitlement."Scheme Code");
        Setup.GetSetup();
        if SalesHeader."Document Type" = SalesHeader."Document Type"::Order then begin
            if not Line.Get(SalesHeader."Document Type", SalesHeader."No.", 10000) then
                Error(InvalidRewardErr, 10000, SalesHeader."No.");
            if (Line.Type <> Line.Type::Item) or (Line."No." <> Entitlement."FOC Item No.") or
               (Line.Quantity <> Entitlement."FOC Quantity") or (Line."Unit Price" <> 0) or not Line."PTV FOC Item" or
               ((Entitlement."FOC Unit of Measure" <> '') and (Line."Unit of Measure Code" <> Entitlement."FOC Unit of Measure"))
            then
                Error(InvalidRewardErr, Line."Line No.", SalesHeader."No.");
            RequireZeroVAT := Header."Suppress VAT on FOC";
        end else begin
            if not Line.Get(SalesHeader."Document Type", SalesHeader."No.", 10000) then
                Error(InvalidCreditErr, SalesHeader."No.");
            if (Line.Type <> Line.Type::"G/L Account") or (Line.Quantity <> 1) or (Line."Unit Price" <> Entitlement."Total Rebate Amount") or
               (Line."Line Discount Amount" <> 0) or (Line."Inv. Discount Amount" <> 0)
            then
                Error(InvalidCreditErr, SalesHeader."No.");
            RequireZeroVAT := Header."Suppress VAT on Credit Notes" or Setup."Suppress VAT on Credit Notes";
        end;
        if SalesHeader."Document Type" = SalesHeader."Document Type"::"Credit Memo" then begin
            ExtraLine.SetRange("Document Type", SalesHeader."Document Type");
            ExtraLine.SetRange("Document No.", SalesHeader."No.");
            ExtraLine.SetFilter("Line No.", '<>%1', 10000);
            ExtraLine.SetFilter(Type, '<>%1', ExtraLine.Type::" ");
            if not ExtraLine.IsEmpty() then
                Error(InvalidCreditErr, SalesHeader."No.");
        end;
        if RequireZeroVAT then
            if (Line."VAT %" <> 0) or
               (Line."VAT Bus. Posting Group" <> Setup."Zero VAT Business Group") or
               (Line."VAT Prod. Posting Group" <> Setup."Zero VAT Product Group")
            then
                Error(ZeroVATErr, SalesHeader."No.", Line."Line No.");
    end;

    local procedure VerifyArchivedFOCOrder(SalesHeader: Record "Sales Header")
    var
        Archived: Record "PTV Posted Scheme Entitlement";
        Line: Record "Sales Line";
        MissingErr: Label 'The entitlement linked to scheme document %1 is unavailable.';
    begin
        if SalesHeader."Document Type" <> SalesHeader."Document Type"::Order then
            Error(MissingErr, SalesHeader."No.");
        Archived.SetRange("Original Entry No.", SalesHeader."PTV Scheme Entitlement Entry");
        Archived.SetRange("FOC Sales Order No.", SalesHeader."No.");
        if not Archived.FindFirst() then
            Error(MissingErr, SalesHeader."No.");
        SalesHeader.TestField("Sell-to Customer No.", Archived."Customer No.");
        Line.Get(SalesHeader."Document Type", SalesHeader."No.", 10000);
        Line.TestField("No.", Archived."FOC Item No.");
        Line.TestField(Quantity, Archived."FOC Quantity");
        Line.TestField("PTV FOC Item", true);
        Line.TestField("Unit Price", 0);
        Line.TestField("Qty. to Ship", 0);
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
