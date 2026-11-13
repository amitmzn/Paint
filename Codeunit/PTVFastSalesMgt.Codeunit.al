codeunit 76214 "PTV Fast Sales Mgt"
{
    /// <summary>
    /// Creates a sales invoice and fills the cash customer, store, and responsibility centre.
    /// </summary>
    procedure CreateInvoice(var SalesHeader: Record "Sales Header")
    var
        LocationCode: Code[10];
        CustomerNo: Code[20];
        RespCenter: Code[10];
    begin
        ResolveContext(LocationCode, CustomerNo, RespCenter);
        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::Invoice;
        SalesHeader."PTV Fast Sales" := true;
        SalesHeader.Insert(true);
        SalesHeader.Validate("Sell-to Customer No.", CustomerNo);
        if LocationCode <> '' then
            SalesHeader.Validate("Location Code", LocationCode)
        else
            SalesHeader.Validate("Location Code", '');
        if RespCenter <> '' then
            SalesHeader.Validate("Responsibility Center", RespCenter)
        else
            SalesHeader.Validate("Responsibility Center", '');
        SalesHeader."PTV Fast Sales" := true;
        SalesHeader.Modify(true);
    end;

    /// <summary>
    /// Returns whether the barcode field is shown for the invoice location.
    /// </summary>
    procedure BarcodeScanningEnabled(LocationCode: Code[10]): Boolean
    var
        FastSalesStore: Record "PTV Fast Sales Store";
        PaintSetup: Record "PTV Paint Setup";
    begin
        if (LocationCode <> '') and FastSalesStore.Get(LocationCode) then
            exit(FastSalesStore."Barcode Scanning");
        PaintSetup.SetLoadFields("Fast Sales Barcode");
        PaintSetup.GetSetup();
        exit(PaintSetup."Fast Sales Barcode");
    end;

    /// <summary>
    /// Adds quantity 1 for the item identified by a bar code item reference.
    /// </summary>
    procedure AddBarcode(var SalesLine: Record "Sales Line"; ScannedCode: Code[50])
    var
        ItemReference: Record "Item Reference";
        ExistingLine: Record "Sales Line";
        OpenInvoiceFirstErr: Label 'Open a fast sales invoice before scanning a barcode.';
        BarcodeNotFoundErr: Label 'Barcode %1 is not an item reference of type Bar Code.', Comment = '%1 = scanned barcode';
        BarcodeAmbiguousErr: Label 'Barcode %1 matches more than one item.', Comment = '%1 = scanned barcode';
    begin
        if ScannedCode = '' then
            exit;
        if SalesLine."Document No." = '' then
            Error(OpenInvoiceFirstErr);

        ItemReference.SetRange("Reference Type", ItemReference."Reference Type"::"Bar Code");
        ItemReference.SetRange("Reference No.", ScannedCode);
        if ItemReference.IsEmpty() then
            Error(BarcodeNotFoundErr, ScannedCode);
        if ItemReference.Count() > 1 then
            Error(BarcodeAmbiguousErr, ScannedCode);
        ItemReference.FindFirst();

        if CurrentLineMatchesItem(SalesLine, ItemReference) then begin
            SalesLine.Validate(Quantity, SalesLine.Quantity + 1);
            SalesLine.Modify(true);
            exit;
        end;

        ExistingLine.SetRange("Document Type", SalesLine."Document Type");
        ExistingLine.SetRange("Document No.", SalesLine."Document No.");
        ExistingLine.SetRange(Type, ExistingLine.Type::Item);
        ExistingLine.SetRange("No.", ItemReference."Item No.");
        if ItemReference."Variant Code" <> '' then
            ExistingLine.SetRange("Variant Code", ItemReference."Variant Code");
        if ItemReference."Unit of Measure" <> '' then
            ExistingLine.SetRange("Unit of Measure Code", ItemReference."Unit of Measure");
        if ExistingLine.FindLast() then begin
            ExistingLine.Validate(Quantity, ExistingLine.Quantity + 1);
            ExistingLine.Modify(true);
            SalesLine := ExistingLine;
            exit;
        end;

        if (SalesLine.Type = SalesLine.Type::" ") and (SalesLine."No." = '') then begin
            EnsureLineInserted(SalesLine);
            FillItemLine(SalesLine, ItemReference);
            exit;
        end;

        ExistingLine.Init();
        ExistingLine."Document Type" := SalesLine."Document Type";
        ExistingLine."Document No." := SalesLine."Document No.";
        ExistingLine."Line No." := NextLineNo(SalesLine);
        ExistingLine.Insert(true);
        FillItemLine(ExistingLine, ItemReference);
        SalesLine := ExistingLine;
    end;

    /// <summary>
    /// Lot or serial numbers must be entered when outbound tracking is on and no number series assigns them.
    /// </summary>
    procedure RequiresManualTracking(SalesLine: Record "Sales Line"): Boolean
    var
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
    begin
        if (SalesLine.Type <> SalesLine.Type::Item) or (SalesLine."No." = '') then
            exit(false);
        Item.SetLoadFields("Item Tracking Code");
        if not Item.Get(SalesLine."No.") then
            exit(false);
        if Item."Item Tracking Code" = '' then
            exit(false);
        ItemTrackingCode.SetLoadFields(
            "Lot Sales Outbound Tracking", "SN Sales Outbound Tracking", "Lot Nos.", "SN Nos.");
        if not ItemTrackingCode.Get(Item."Item Tracking Code") then
            exit(false);
        exit(
            (ItemTrackingCode."Lot Sales Outbound Tracking" and (ItemTrackingCode."Lot Nos." = '')) or
            (ItemTrackingCode."SN Sales Outbound Tracking" and (ItemTrackingCode."SN Nos." = '')));
    end;

    /// <summary>
    /// Opens the item tracking lines page for a saved line that already has a quantity.
    /// </summary>
    procedure OpenItemTracking(var SalesLine: Record "Sales Line")
    var
        LineNotReadyErr: Label 'Enter the item and quantity before item tracking.';
    begin
        if (SalesLine."Line No." = 0) or (SalesLine."No." = '') or (SalesLine.Quantity = 0) then
            Error(LineNotReadyErr);
        SalesLine.OpenItemTrackingLines();
    end;

    /// <summary>
    /// Returns the entered lot or serial numbers, or a prompt when manual tracking is still empty.
    /// </summary>
    procedure TrackingStatusText(SalesLine: Record "Sales Line"): Text[100]
    var
        ReservationEntry: Record "Reservation Entry";
        StatusText: Text;
        FirstNo: Code[50];
        EntryCount: Integer;
        EnterLotLbl: Label 'Enter lot';
        MoreLotsLbl: Label '%1 (+%2)', Comment = '%1 = first lot or serial number, %2 = additional count';
    begin
        if not RequiresManualTracking(SalesLine) then
            exit('');
        if SalesLine."Line No." = 0 then
            exit(EnterLotLbl);

        ReservationEntry.SetRange("Source Type", Database::"Sales Line");
        ReservationEntry.SetRange("Source Subtype", SalesLine."Document Type".AsInteger());
        ReservationEntry.SetRange("Source ID", SalesLine."Document No.");
        ReservationEntry.SetRange("Source Ref. No.", SalesLine."Line No.");
        ReservationEntry.SetRange(Positive, false);
        ReservationEntry.SetFilter("Item Tracking", '<>%1', ReservationEntry."Item Tracking"::None);
        if ReservationEntry.FindSet() then
            repeat
                EntryCount += 1;
                if EntryCount = 1 then
                    if ReservationEntry."Lot No." <> '' then
                        FirstNo := ReservationEntry."Lot No."
                    else
                        FirstNo := ReservationEntry."Serial No.";
            until ReservationEntry.Next() = 0;

        if EntryCount = 0 then
            exit(EnterLotLbl);
        if EntryCount = 1 then
            exit(CopyStr(FirstNo, 1, 100));
        StatusText := StrSubstNo(MoreLotsLbl, FirstNo, EntryCount - 1);
        exit(CopyStr(StatusText, 1, 100));
    end;

    local procedure ResolveContext(var LocationCode: Code[10]; var CustomerNo: Code[20]; var RespCenter: Code[10])
    var
        UserSetup: Record "User Setup";
        FastSalesStore: Record "PTV Fast Sales Store";
        PaintSetup: Record "PTV Paint Setup";
        StoreNotConfiguredErr: Label 'Store %1 on User Setup has no Fast Sales Store setup.', Comment = '%1 = store location';
        StoreCustomerMissingErr: Label 'Set a cash customer for store %1.', Comment = '%1 = store location';
        DefaultCustomerMissingErr: Label 'Set a default cash customer on Paint Setup, or assign a store on User Setup.';
    begin
        LocationCode := '';
        CustomerNo := '';
        RespCenter := '';

        if UserSetup.Get(UserId()) and (UserSetup."PTV Store Location Code" <> '') then begin
            if not FastSalesStore.Get(UserSetup."PTV Store Location Code") then
                Error(StoreNotConfiguredErr, UserSetup."PTV Store Location Code");
            if FastSalesStore."Cash Customer No." = '' then
                Error(StoreCustomerMissingErr, FastSalesStore."Location Code");
            EnsureCenterAllowed(UserSetup, FastSalesStore);
            LocationCode := FastSalesStore."Location Code";
            CustomerNo := FastSalesStore."Cash Customer No.";
            RespCenter := FastSalesStore."Responsibility Center";
            exit;
        end;

        PaintSetup.SetLoadFields("Default Cash Customer");
        PaintSetup.GetSetup();
        if PaintSetup."Default Cash Customer" = '' then
            Error(DefaultCustomerMissingErr);
        CustomerNo := PaintSetup."Default Cash Customer";
    end;

    local procedure EnsureCenterAllowed(UserSetup: Record "User Setup"; FastSalesStore: Record "PTV Fast Sales Store")
    var
        ResponsibilityCenter: Record "Responsibility Center";
        StoreCenterOutsideFilterErr: Label 'Responsibility centre %1 for store %2 is outside your sales responsibility centre filter.', Comment = '%1 = responsibility centre, %2 = store location';
    begin
        if UserSetup."Sales Resp. Ctr. Filter" = '' then
            exit;
        if FastSalesStore."Responsibility Center" = '' then
            Error(StoreCenterOutsideFilterErr, FastSalesStore."Responsibility Center", FastSalesStore."Location Code");

        ResponsibilityCenter.SetFilter(Code, UserSetup."Sales Resp. Ctr. Filter");
        if ResponsibilityCenter.FindSet() then
            repeat
                if ResponsibilityCenter.Code = FastSalesStore."Responsibility Center" then
                    exit;
            until ResponsibilityCenter.Next() = 0;
        Error(StoreCenterOutsideFilterErr, FastSalesStore."Responsibility Center", FastSalesStore."Location Code");
    end;

    local procedure CurrentLineMatchesItem(SalesLine: Record "Sales Line"; ItemReference: Record "Item Reference"): Boolean
    begin
        if SalesLine."Line No." = 0 then
            exit(false);
        if SalesLine.Type <> SalesLine.Type::Item then
            exit(false);
        if SalesLine."No." <> ItemReference."Item No." then
            exit(false);
        if (ItemReference."Variant Code" <> '') and (SalesLine."Variant Code" <> ItemReference."Variant Code") then
            exit(false);
        if (ItemReference."Unit of Measure" <> '') and (SalesLine."Unit of Measure Code" <> ItemReference."Unit of Measure") then
            exit(false);
        exit(true);
    end;

    local procedure FillItemLine(var SalesLine: Record "Sales Line"; ItemReference: Record "Item Reference")
    begin
        SalesLine.Validate(Type, SalesLine.Type::Item);
        SalesLine.Validate("No.", ItemReference."Item No.");
        if ItemReference."Variant Code" <> '' then
            SalesLine.Validate("Variant Code", ItemReference."Variant Code");
        if ItemReference."Unit of Measure" <> '' then
            SalesLine.Validate("Unit of Measure Code", ItemReference."Unit of Measure");
        SalesLine.Validate(Quantity, 1);
        SalesLine.Modify(true);
    end;

    local procedure EnsureLineInserted(var SalesLine: Record "Sales Line")
    begin
        if SalesLine."Line No." <> 0 then
            exit;
        SalesLine."Line No." := NextLineNo(SalesLine);
        SalesLine.Insert(true);
    end;

    local procedure NextLineNo(SalesLine: Record "Sales Line"): Integer
    var
        LastLine: Record "Sales Line";
    begin
        LastLine.SetRange("Document Type", SalesLine."Document Type");
        LastLine.SetRange("Document No.", SalesLine."Document No.");
        if LastLine.FindLast() then
            exit(LastLine."Line No." + 10000);
        exit(10000);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Invoice Header", OnBeforeInsertEvent, '', false, false)]
    local procedure MarkPostedFastSales(var Rec: Record "Sales Invoice Header"; RunTrigger: Boolean)
    var
        SalesHeader: Record "Sales Header";
    begin
        if Rec.IsTemporary then
            exit;
        if Rec."Pre-Assigned No." = '' then
            exit;
        if not SalesHeader.Get(SalesHeader."Document Type"::Invoice, Rec."Pre-Assigned No.") then
            exit;
        if SalesHeader."PTV Fast Sales" then
            Rec."PTV Fast Sales" := true;
    end;
}
