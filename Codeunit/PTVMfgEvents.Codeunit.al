codeunit 76206 "PTV Mfg Events"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Prod. Order Status Management", OnAfterChangeStatusOnProdOrder, '', false, false)]
    local procedure HandleChangeStatusOnProdOrder(var ProdOrder: Record "Production Order"; var ToProdOrder: Record "Production Order"; NewStatus: Enum "Production Order Status"; NewPostingDate: Date; NewUpdateUnitCost: Boolean; var SuppressCommit: Boolean; xProductionOrder: Record "Production Order")
    var
        PaintSetup: Record "PTV Paint Setup";
        CompReservation: Codeunit "PTV Comp Reservation";
        FGAutoTransferMgt: Codeunit "PTV FG Auto-Transfer Mgt";
    begin
        if NewStatus = NewStatus::Finished then begin
            FGAutoTransferMgt.TransferFinishedOrder(ToProdOrder);
            exit;
        end;

        if NewStatus <> NewStatus::Released then
            exit;
        if ToProdOrder."PTV Batch No." <> '' then
            exit;

        PaintSetup.GetSetup();
        PaintSetup.TestField("Batch Nos.");
        ToProdOrder."PTV Batch No." := GetNextBatchNo(PaintSetup."Batch Nos.");
        SnapshotPaintFields(ToProdOrder);
        RequireLotTracking(ToProdOrder);
        ToProdOrder.Modify(true);
        SyncBatchTracking(ToProdOrder);

        if PaintSetup."Auto Reserve On Release" then
            CompReservation.AutoReserveComponents(ToProdOrder);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", OnBeforePostItemJnlLine, '', false, false)]
    local procedure AssignOutputLot(var ItemJournalLine: Record "Item Journal Line"; CalledFromAdjustment: Boolean; CalledFromInvtPutawayPick: Boolean; var ItemRegister: Record "Item Register"; var ItemLedgEntryNo: Integer; var ValueEntryNo: Integer; var ItemApplnEntryNo: Integer; var PhysicalInventoryEntryNo: Integer; var CapacityLedgerEntryNo: Integer)
    var
        ProdOrder: Record "Production Order";
        LotMissingErr: Label 'Finished-goods lot %1 is required on output for production order %2. The lot must equal the paint batch number.', Comment = '%1 = batch, %2 = order';
    begin
        if ItemJournalLine."Entry Type" <> ItemJournalLine."Entry Type"::Output then
            exit;
        if ItemJournalLine."Order No." = '' then
            exit;
        ProdOrder.SetLoadFields("PTV Batch No.");
        if not ProdOrder.Get(ProdOrder.Status::Released, ItemJournalLine."Order No.") then
            exit;
        if ProdOrder."PTV Batch No." = '' then
            exit;
        if ItemJournalLine."Lot No." = '' then
            ItemJournalLine."Lot No." := ProdOrder."PTV Batch No.";
        if ItemJournalLine."Lot No." <> ProdOrder."PTV Batch No." then
            Error(ErrorInfo.Create(StrSubstNo(LotMissingErr, ProdOrder."PTV Batch No.", ItemJournalLine."Order No.")));
    end;

    local procedure GetNextBatchNo(SeriesCode: Code[20]): Code[20]
    var
        NoSeries: Codeunit "No. Series";
    begin
        exit(NoSeries.GetNextNo(SeriesCode, WorkDate(), false));
    end;

    local procedure SnapshotPaintFields(var ProdOrder: Record "Production Order")
    var
        Item: Record Item;
    begin
        Item.SetLoadFields("PTV Specific Gravity", "PTV Product Code", "PTV Shade Code", "Item Tracking Code");
        if ProdOrder."Source Type" <> ProdOrder."Source Type"::Item then
            exit;
        if not Item.Get(ProdOrder."Source No.") then
            exit;
        ProdOrder."PTV Specific Gravity" := Item."PTV Specific Gravity";
        if ProdOrder."PTV Formula No." = '' then
            ProdOrder."PTV Formula No." := Item."PTV Product Code";
        if ProdOrder."PTV Shade Code" = '' then
            ProdOrder."PTV Shade Code" := Item."PTV Shade Code";
    end;

    local procedure RequireLotTracking(ProdOrder: Record "Production Order")
    var
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
        TrackingErr: Label 'Item %1 must use lot tracking before a paint batch can be released.', Comment = '%1 = item no.';
    begin
        if ProdOrder."Source Type" <> ProdOrder."Source Type"::Item then
            exit;
        Item.SetLoadFields("Item Tracking Code", "PTV Item Role");
        if not Item.Get(ProdOrder."Source No.") then
            exit;
        if not (Item."PTV Item Role" in [Item."PTV Item Role"::"FG Paint", Item."PTV Item Role"::Bulk, Item."PTV Item Role"::"Tinted Base"]) then
            exit;
        if not ItemTrackingCode.Get(Item."Item Tracking Code") then
            Error(ErrorInfo.Create(StrSubstNo(TrackingErr, Item."No.")));
        if not ItemTrackingCode."Lot Specific Tracking" then
            Error(ErrorInfo.Create(StrSubstNo(TrackingErr, Item."No.")));
    end;

    procedure SyncBatchTracking(ProdOrder: Record "Production Order")
    var
        ProdOrderLine: Record "Prod. Order Line";
    begin
        if ProdOrder."No." = '' then
            exit;
        ProdOrderLine.SetRange(Status, ProdOrder.Status);
        ProdOrderLine.SetRange("Prod. Order No.", ProdOrder."No.");
        if ProdOrderLine.FindSet() then
            repeat
                AssignBatchTrackingForLine(ProdOrder, ProdOrderLine);
            until ProdOrderLine.Next() = 0;
    end;

    procedure AssignBatchTrackingForLine(ProdOrder: Record "Production Order"; ProdOrderLine: Record "Prod. Order Line")
    var
        Item: Record Item;
        ItemTrackingCode: Record "Item Tracking Code";
        ReservationEntry: Record "Reservation Entry";
    begin
        if (ProdOrderLine."Item No." = '') or (ProdOrderLine."Remaining Qty. (Base)" <= 0) then
            exit;
        if not Item.Get(ProdOrderLine."Item No.") then
            exit;
        if Item."Item Tracking Code" = '' then
            exit;
        if not ItemTrackingCode.Get(Item."Item Tracking Code") then
            exit;
        if not ItemTrackingCode."Lot Specific Tracking" then
            exit;

        ReservationEntry.SetRange("Source Type", Database::"Prod. Order Line");
        ReservationEntry.SetRange("Source Subtype", ProdOrderLine.Status.AsInteger());
        ReservationEntry.SetRange("Source ID", ProdOrderLine."Prod. Order No.");
        ReservationEntry.SetRange("Source Prod. Order Line", ProdOrderLine."Line No.");
        ReservationEntry.SetRange("Reservation Status", ReservationEntry."Reservation Status"::Surplus);

        if ProdOrder."PTV Batch No." = '' then begin
            if not ReservationEntry.IsEmpty() then
                ReservationEntry.DeleteAll(true);
            exit;
        end;

        if ReservationEntry.FindFirst() then begin
            if (ReservationEntry."Lot No." <> ProdOrder."PTV Batch No.") or
               (ReservationEntry."Quantity (Base)" <> ProdOrderLine."Remaining Qty. (Base)") then begin
                ReservationEntry."Lot No." := ProdOrder."PTV Batch No.";
                ReservationEntry.Quantity := ProdOrderLine."Remaining Quantity";
                ReservationEntry."Quantity (Base)" := ProdOrderLine."Remaining Qty. (Base)";
                ReservationEntry."Qty. to Handle (Base)" := ProdOrderLine."Remaining Qty. (Base)";
                ReservationEntry."Qty. to Invoice (Base)" := ProdOrderLine."Remaining Qty. (Base)";
                ReservationEntry.Modify(true);
            end;
        end else begin
            ReservationEntry.Init();
            ReservationEntry."Entry No." := NextReservationEntryNo();
            ReservationEntry.Positive := true;
            ReservationEntry."Item No." := ProdOrderLine."Item No.";
            ReservationEntry."Variant Code" := ProdOrderLine."Variant Code";
            ReservationEntry."Location Code" := ProdOrderLine."Location Code";
            ReservationEntry."Lot No." := ProdOrder."PTV Batch No.";
            ReservationEntry."Reservation Status" := ReservationEntry."Reservation Status"::Surplus;
            ReservationEntry."Source Type" := Database::"Prod. Order Line";
            ReservationEntry."Source Subtype" := ProdOrderLine.Status.AsInteger();
            ReservationEntry."Source ID" := ProdOrderLine."Prod. Order No.";
            ReservationEntry."Source Prod. Order Line" := ProdOrderLine."Line No.";
            ReservationEntry."Source Ref. No." := 0;
            ReservationEntry."Qty. per Unit of Measure" := ProdOrderLine."Qty. per Unit of Measure";
            ReservationEntry.Quantity := ProdOrderLine."Remaining Quantity";
            ReservationEntry."Quantity (Base)" := ProdOrderLine."Remaining Qty. (Base)";
            ReservationEntry."Qty. to Handle (Base)" := ProdOrderLine."Remaining Qty. (Base)";
            ReservationEntry."Qty. to Invoice (Base)" := ProdOrderLine."Remaining Qty. (Base)";
            ReservationEntry."Expected Receipt Date" := ProdOrderLine."Due Date";
            ReservationEntry."Item Tracking" := ReservationEntry."Item Tracking"::"Lot No.";
            ReservationEntry."Created By" := CopyStr(UserId(), 1, MaxStrLen(ReservationEntry."Created By"));
            ReservationEntry."Creation Date" := WorkDate();
            ReservationEntry.Insert(true);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Prod. Order Line", OnAfterInsertEvent, '', false, false)]
    local procedure AutoTrackOnProdOrderLineInsert(var Rec: Record "Prod. Order Line"; RunTrigger: Boolean)
    var
        ProdOrder: Record "Production Order";
    begin
        if Rec.IsTemporary then
            exit;
        if not ProdOrder.Get(Rec.Status, Rec."Prod. Order No.") then
            exit;
        if ProdOrder."PTV Batch No." <> '' then
            AssignBatchTrackingForLine(ProdOrder, Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Prod. Order Line", OnAfterModifyEvent, '', false, false)]
    local procedure AutoTrackOnProdOrderLineModify(var Rec: Record "Prod. Order Line"; var xRec: Record "Prod. Order Line"; RunTrigger: Boolean)
    var
        ProdOrder: Record "Production Order";
    begin
        if Rec.IsTemporary then
            exit;
        if Rec."Remaining Qty. (Base)" = xRec."Remaining Qty. (Base)" then
            exit;
        if not ProdOrder.Get(Rec.Status, Rec."Prod. Order No.") then
            exit;
        if ProdOrder."PTV Batch No." <> '' then
            AssignBatchTrackingForLine(ProdOrder, Rec);
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
