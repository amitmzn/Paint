codeunit 76206 "PTV Mfg Events"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Prod. Order Status Management", OnAfterChangeStatusOnProdOrder, '', false, false)]
    local procedure StampBatchOnRelease(var ProdOrder: Record "Production Order"; var ToProdOrder: Record "Production Order"; NewStatus: Enum "Production Order Status"; NewPostingDate: Date; NewUpdateUnitCost: Boolean; var SuppressCommit: Boolean; xProductionOrder: Record "Production Order")
    var
        PaintSetup: Record "PTV Paint Setup";
        CompReservation: Codeunit "PTV Comp Reservation";
    begin
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
}
