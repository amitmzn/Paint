codeunit 76215 "PTV FG Auto-Transfer Mgt"
{
    Access = Public;

    /// <summary>
    /// Automatically transfers finished goods from the production location to the shipment location upon finishing a production order.
    /// </summary>
    /// <param name="ProdOrder">Finished production order record.</param>
    procedure TransferFinishedOrder(ProdOrder: Record "Production Order")
    var
        PaintSetup: Record "PTV Paint Setup";
        Item: Record Item;
        ItemLedgerEntry: Record "Item Ledger Entry";
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
        LineNo: Integer;
    begin
        PaintSetup.GetSetup();
        if not PaintSetup."Auto Transfer FG On Finish" then
            exit;

        PaintSetup.TestField("FG Shipment Location");
        PaintSetup.TestField("FG Reclass Template Name");
        PaintSetup.TestField("FG Reclass Batch Name");

        if (ProdOrder."Location Code" = '') or (ProdOrder."Location Code" = PaintSetup."FG Shipment Location") then
            exit;

        if ProdOrder."Source Type" <> ProdOrder."Source Type"::Item then
            exit;

        if not Item.Get(ProdOrder."Source No.") then
            exit;

        if Item."PTV Item Role" <> Item."PTV Item Role"::"FG Paint" then
            exit;

        ItemLedgerEntry.SetLoadFields("Entry No.", "Item No.", "Variant Code", "Unit of Measure Code", "Qty. per Unit of Measure", "Remaining Quantity", "Lot No.", "Serial No.", "Expiration Date", "Order Line No.");
        ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::Output);
        ItemLedgerEntry.SetRange("Order Type", ItemLedgerEntry."Order Type"::Production);
        ItemLedgerEntry.SetRange("Order No.", ProdOrder."No.");
        ItemLedgerEntry.SetRange("Location Code", ProdOrder."Location Code");
        if ProdOrder."PTV Batch No." <> '' then
            ItemLedgerEntry.SetRange("Lot No.", ProdOrder."PTV Batch No.");
        ItemLedgerEntry.SetRange(Open, true);
        ItemLedgerEntry.SetFilter("Remaining Quantity", '>0');
        if not ItemLedgerEntry.FindSet() then
            exit;

        LineNo := GetNextLineNo(PaintSetup."FG Reclass Template Name", PaintSetup."FG Reclass Batch Name");

        repeat
            PostReclassLine(ItemLedgerEntry, ProdOrder, PaintSetup, LineNo, ItemJnlPostLine);
            LineNo += 10000;
        until ItemLedgerEntry.Next() = 0;
    end;

    local procedure PostReclassLine(
        var ItemLedgerEntry: Record "Item Ledger Entry";
        ProdOrder: Record "Production Order";
        PaintSetup: Record "PTV Paint Setup";
        LineNo: Integer;
        var ItemJnlPostLine: Codeunit "Item Jnl.-Post Line")
    var
        ItemJournalLine: Record "Item Journal Line";
        Item: Record Item;
    begin
        ItemJournalLine.Init();
        ItemJournalLine."Journal Template Name" := PaintSetup."FG Reclass Template Name";
        ItemJournalLine."Journal Batch Name" := PaintSetup."FG Reclass Batch Name";
        ItemJournalLine."Line No." := LineNo;
        ItemJournalLine."Posting Date" := WorkDate();
        ItemJournalLine."Document Date" := WorkDate();
        ItemJournalLine."Entry Type" := ItemJournalLine."Entry Type"::Transfer;
        ItemJournalLine."Document No." := ProdOrder."No.";
        ItemJournalLine.Description := ProdOrder.Description;

        ItemJournalLine.Validate("Item No.", ItemLedgerEntry."Item No.");
        ItemJournalLine.Validate("Posting Date", WorkDate());
        ItemJournalLine.Validate("Location Code", ProdOrder."Location Code");
        ItemJournalLine.Validate("New Location Code", PaintSetup."FG Shipment Location");

        if ItemLedgerEntry."Variant Code" <> '' then
            ItemJournalLine.Validate("Variant Code", ItemLedgerEntry."Variant Code");

        if (ItemLedgerEntry."Unit of Measure Code" <> '') and (ItemLedgerEntry."Qty. per Unit of Measure" > 0) then begin
            ItemJournalLine.Validate("Unit of Measure Code", ItemLedgerEntry."Unit of Measure Code");
            ItemJournalLine.Validate(Quantity, ItemLedgerEntry."Remaining Quantity" / ItemLedgerEntry."Qty. per Unit of Measure");
        end else begin
            Item.Get(ItemLedgerEntry."Item No.");
            ItemJournalLine.Validate("Unit of Measure Code", Item."Base Unit of Measure");
            ItemJournalLine.Validate(Quantity, ItemLedgerEntry."Remaining Quantity");
        end;

        ApplyItemTrackingToReclassLine(ItemJournalLine, ItemLedgerEntry);

        ItemJnlPostLine.RunWithCheck(ItemJournalLine);
    end;

    local procedure ApplyItemTrackingToReclassLine(
        var ItemJournalLine: Record "Item Journal Line";
        ItemLedgerEntry: Record "Item Ledger Entry")
    var
        ReservationEntry: Record "Reservation Entry";
        HasLot: Boolean;
        HasSerial: Boolean;
    begin
        HasLot := ItemLedgerEntry."Lot No." <> '';
        HasSerial := ItemLedgerEntry."Serial No." <> '';

        if (not HasLot) and (not HasSerial) then
            exit;

        ReservationEntry.Init();
        ReservationEntry."Entry No." := NextReservationEntryNo();
        ReservationEntry.Positive := false;
        ReservationEntry."Item No." := ItemJournalLine."Item No.";
        ReservationEntry."Location Code" := ItemJournalLine."Location Code";
        ReservationEntry.Quantity := -Abs(ItemJournalLine.Quantity);
        ReservationEntry."Quantity (Base)" := -Abs(ItemJournalLine."Quantity (Base)");
        ReservationEntry."Qty. to Handle (Base)" := ReservationEntry."Quantity (Base)";
        ReservationEntry."Qty. to Invoice (Base)" := ReservationEntry."Quantity (Base)";
        ReservationEntry."Qty. per Unit of Measure" := ItemJournalLine."Qty. per Unit of Measure";

        if HasLot then begin
            ReservationEntry."Lot No." := ItemLedgerEntry."Lot No.";
            ReservationEntry."New Lot No." := ItemLedgerEntry."Lot No.";
        end;

        if HasSerial then begin
            ReservationEntry."Serial No." := ItemLedgerEntry."Serial No.";
            ReservationEntry."New Serial No." := ItemLedgerEntry."Serial No.";
        end;

        if HasLot and HasSerial then
            ReservationEntry."Item Tracking" := ReservationEntry."Item Tracking"::"Lot and Serial No."
        else if HasLot then
            ReservationEntry."Item Tracking" := ReservationEntry."Item Tracking"::"Lot No."
        else
            ReservationEntry."Item Tracking" := ReservationEntry."Item Tracking"::"Serial No.";

        if ItemLedgerEntry."Expiration Date" <> 0D then begin
            ReservationEntry."Expiration Date" := ItemLedgerEntry."Expiration Date";
            ReservationEntry."New Expiration Date" := ItemLedgerEntry."Expiration Date";
        end;

        ReservationEntry."Reservation Status" := ReservationEntry."Reservation Status"::Surplus;
        ReservationEntry."Source Type" := Database::"Item Journal Line";
        ReservationEntry."Source Subtype" := ItemJournalLine."Entry Type".AsInteger();
        ReservationEntry."Source ID" := ItemJournalLine."Journal Template Name";
        ReservationEntry."Source Batch Name" := ItemJournalLine."Journal Batch Name";
        ReservationEntry."Source Ref. No." := ItemJournalLine."Line No.";
        ReservationEntry."Source Prod. Order Line" := 0;
        ReservationEntry."Shipment Date" := ItemJournalLine."Posting Date";
        ReservationEntry."Expected Receipt Date" := ItemJournalLine."Posting Date";
        ReservationEntry."Created By" := CopyStr(UserId(), 1, MaxStrLen(ReservationEntry."Created By"));
        ReservationEntry."Creation Date" := WorkDate();
        if ItemJournalLine."Variant Code" <> '' then
            ReservationEntry."Variant Code" := ItemJournalLine."Variant Code";
        ReservationEntry.Insert(true);
    end;

    /// <summary>
    /// Inserts a reservation entry with Lot No and New Lot No for the reclassification line.
    /// </summary>
    /// <param name="ItemJournalLine">The item journal line being tracked.</param>
    /// <param name="LotNo">Current Lot No.</param>
    /// <param name="NewLotNo">New Lot No for the transfer destination.</param>
    procedure CreateReservationEntry(
        var ItemJournalLine: Record "Item Journal Line";
        LotNo: Code[50];
        NewLotNo: Code[50])
    begin
        CreateReservationEntry(ItemJournalLine, LotNo, NewLotNo, ItemJournalLine.Quantity, ItemJournalLine."Quantity (Base)");
    end;

    /// <summary>
    /// Inserts a reservation entry with Lot No and New Lot No for the reclassification line.
    /// </summary>
    /// <param name="ItemJournalLine">The item journal line being tracked.</param>
    /// <param name="LotNo">Current Lot No.</param>
    /// <param name="NewLotNo">New Lot No for the transfer destination.</param>
    /// <param name="Qty">Quantity in journal line unit of measure.</param>
    /// <param name="QtyBase">Quantity in base unit of measure.</param>
    procedure CreateReservationEntry(
        var ItemJournalLine: Record "Item Journal Line";
        LotNo: Code[50];
        NewLotNo: Code[50];
        Qty: Decimal;
        QtyBase: Decimal)
    var
        ReservationEntry: Record "Reservation Entry";
    begin
        ReservationEntry.Init();
        ReservationEntry."Entry No." := NextReservationEntryNo();
        ReservationEntry.Positive := false;
        ReservationEntry."Item No." := ItemJournalLine."Item No.";
        ReservationEntry."Location Code" := ItemJournalLine."Location Code";
        ReservationEntry.Quantity := -Abs(Qty);
        ReservationEntry."Quantity (Base)" := -Abs(QtyBase);
        ReservationEntry."Qty. to Handle (Base)" := ReservationEntry."Quantity (Base)";
        ReservationEntry."Qty. to Invoice (Base)" := ReservationEntry."Quantity (Base)";
        ReservationEntry."Qty. per Unit of Measure" := ItemJournalLine."Qty. per Unit of Measure";
        ReservationEntry."Lot No." := LotNo;
        ReservationEntry."New Lot No." := NewLotNo;
        ReservationEntry."Reservation Status" := ReservationEntry."Reservation Status"::Surplus;
        ReservationEntry."Source Type" := Database::"Item Journal Line";
        ReservationEntry."Source Subtype" := ItemJournalLine."Entry Type".AsInteger();
        ReservationEntry."Source ID" := ItemJournalLine."Journal Template Name";
        ReservationEntry."Source Batch Name" := ItemJournalLine."Journal Batch Name";
        ReservationEntry."Source Ref. No." := ItemJournalLine."Line No.";
        ReservationEntry."Source Prod. Order Line" := 0;
        ReservationEntry."Item Tracking" := ReservationEntry."Item Tracking"::"Lot No.";
        ReservationEntry."Shipment Date" := ItemJournalLine."Posting Date";
        ReservationEntry."Expected Receipt Date" := ItemJournalLine."Posting Date";
        ReservationEntry."Created By" := CopyStr(UserId(), 1, MaxStrLen(ReservationEntry."Created By"));
        ReservationEntry."Creation Date" := WorkDate();
        if ItemJournalLine."Variant Code" <> '' then
            ReservationEntry."Variant Code" := ItemJournalLine."Variant Code";
        ReservationEntry.Insert(true);
    end;

    local procedure GetNextLineNo(TemplateName: Code[10]; BatchName: Code[10]): Integer
    var
        ItemJournalLine: Record "Item Journal Line";
    begin
        ItemJournalLine.SetRange("Journal Template Name", TemplateName);
        ItemJournalLine.SetRange("Journal Batch Name", BatchName);
        if ItemJournalLine.FindLast() then
            exit(ItemJournalLine."Line No." + 10000);
        exit(10000);
    end;

    local procedure NextReservationEntryNo(): Integer
    var
        ReservationEntry: Record "Reservation Entry";
    begin
        ReservationEntry.LockTable();
        if ReservationEntry.FindLast() then
            exit(ReservationEntry."Entry No." + 1);
        exit(1);
    end;
}
