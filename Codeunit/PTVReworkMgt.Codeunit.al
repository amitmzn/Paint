codeunit 76208 "PTV Rework Mgt"
{
    /// <summary>
    /// Creates a firm-planned rework order that consumes the original batch as component line 10000.
    /// </summary>
    /// <param name="ProdOrder">Failed or completed order whose batch should be reworked.</param>
    procedure SuggestReworkComponents(ProdOrder: Record "Production Order")
    var
        MissingBatchErr: Label 'Production order %1 has no batch number to rework.', Comment = '%1 = order no.';
    begin
        if ProdOrder."PTV Batch No." = '' then
            Error(ErrorInfo.Create(StrSubstNo(MissingBatchErr, ProdOrder."No.")));
        if ProdOrder."Source Type" <> ProdOrder."Source Type"::Item then
            exit;
        CreateReworkOrder(ProdOrder."Source No.", ProdOrder."PTV Batch No.", ProdOrder.Quantity, ProdOrder."Location Code");
    end;

    /// <summary>
    /// Suggests a rework order from a quality inspection whose result is REWORK.
    /// </summary>
    /// <param name="QltyInspectionHeader">Inspection that finished as REWORK.</param>
    procedure SuggestReworkFromInspection(QltyInspectionHeader: Record "Qlty. Inspection Header")
    var
        ResultErr: Label 'Inspection %1 result is %2. Suggest Rework is available when the result is REWORK.', Comment = '%1 = inspection no., %2 = result';
    begin
        if QltyInspectionHeader."Result Code" <> 'REWORK' then
            Error(ErrorInfo.Create(StrSubstNo(ResultErr, QltyInspectionHeader."No.", QltyInspectionHeader."Result Code")));
        QltyInspectionHeader.TestField("Source Item No.");
        QltyInspectionHeader.TestField("Source Lot No.");
        CreateReworkOrder(QltyInspectionHeader."Source Item No.", QltyInspectionHeader."Source Lot No.", QltyInspectionHeader."Fail Quantity", QltyInspectionHeader."Location Code");
    end;

    local procedure CreateReworkOrder(ItemNo: Code[20]; OriginalBatchNo: Code[50]; Quantity: Decimal; LocationCode: Code[10])
    var
        ManufacturingSetup: Record "Manufacturing Setup";
        ProdOrder: Record "Production Order";
        ProdOrderLine: Record "Prod. Order Line";
        ProdOrderComponent: Record "Prod. Order Component";
        NoSeries: Codeunit "No. Series";
        ReworkQty: Decimal;
    begin
        ReworkQty := Quantity;
        if ReworkQty <= 0 then
            ReworkQty := 1;

        ManufacturingSetup.Get();
        ManufacturingSetup.TestField("Firm Planned Order Nos.");
        ProdOrder.Init();
        ProdOrder.Status := ProdOrder.Status::"Firm Planned";
        ProdOrder."No." := NoSeries.GetNextNo(ManufacturingSetup."Firm Planned Order Nos.", WorkDate(), false);
        ProdOrder.Insert(true);
        ProdOrder.Validate("Source Type", ProdOrder."Source Type"::Item);
        ProdOrder.Validate("Source No.", ItemNo);
        ProdOrder.Validate(Quantity, ReworkQty);
        if LocationCode <> '' then
            ProdOrder.Validate("Location Code", LocationCode);
        ProdOrder."PTV Rework Order" := true;
        ProdOrder."PTV Original Batch No." := CopyStr(OriginalBatchNo, 1, MaxStrLen(ProdOrder."PTV Original Batch No."));
        ProdOrder.Modify(true);

        ProdOrderLine.Init();
        ProdOrderLine.Status := ProdOrder.Status;
        ProdOrderLine."Prod. Order No." := ProdOrder."No.";
        ProdOrderLine."Line No." := 10000;
        ProdOrderLine.Insert(true);
        ProdOrderLine.Validate("Item No.", ItemNo);
        ProdOrderLine.Validate(Quantity, ReworkQty);
        ProdOrderLine.Modify(true);

        ProdOrderComponent.Init();
        ProdOrderComponent.Status := ProdOrder.Status;
        ProdOrderComponent."Prod. Order No." := ProdOrder."No.";
        ProdOrderComponent."Prod. Order Line No." := ProdOrderLine."Line No.";
        ProdOrderComponent."Line No." := 10000;
        ProdOrderComponent.Insert(true);
        ProdOrderComponent.Validate("Item No.", ItemNo);
        ProdOrderComponent.Validate("Quantity per", 1);
        if LocationCode <> '' then
            ProdOrderComponent.Validate("Location Code", LocationCode);
        ProdOrderComponent.Modify(true);
        TrackComponentLot(ProdOrderComponent, OriginalBatchNo);
    end;

    local procedure TrackComponentLot(ProdOrderComponent: Record "Prod. Order Component"; LotNo: Code[50])
    var
        ReservationEntry: Record "Reservation Entry";
    begin
        ReservationEntry.Init();
        ReservationEntry."Entry No." := NextReservationEntryNo();
        ReservationEntry.Positive := false;
        ReservationEntry."Item No." := ProdOrderComponent."Item No.";
        ReservationEntry."Location Code" := ProdOrderComponent."Location Code";
        ReservationEntry."Lot No." := LotNo;
        ReservationEntry."Reservation Status" := ReservationEntry."Reservation Status"::Surplus;
        ReservationEntry."Source Type" := Database::"Prod. Order Component";
        ReservationEntry."Source Subtype" := ProdOrderComponent.Status.AsInteger();
        ReservationEntry."Source ID" := ProdOrderComponent."Prod. Order No.";
        ReservationEntry."Source Prod. Order Line" := ProdOrderComponent."Prod. Order Line No.";
        ReservationEntry."Source Ref. No." := ProdOrderComponent."Line No.";
        ReservationEntry."Qty. per Unit of Measure" := 1;
        ReservationEntry.Quantity := -ProdOrderComponent."Remaining Qty. (Base)";
        ReservationEntry."Quantity (Base)" := -ProdOrderComponent."Remaining Qty. (Base)";
        ReservationEntry."Qty. to Handle (Base)" := ReservationEntry."Quantity (Base)";
        ReservationEntry."Shipment Date" := ProdOrderComponent."Due Date";
        ReservationEntry."Expected Receipt Date" := ProdOrderComponent."Due Date";
        ReservationEntry."Created By" := CopyStr(UserId(), 1, MaxStrLen(ReservationEntry."Created By"));
        ReservationEntry."Creation Date" := WorkDate();
        ReservationEntry.Insert(true);
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
