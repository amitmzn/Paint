/// <summary>
/// Subscribes to the BC 27 planning publishers that are still active on later versions.
/// Production-order events are on "Mfg. Carry Out Action", not the obsolete "Carry Out Action".
/// </summary>
codeunit 76331 "PTV Planning Trace Events"
{
    Access = Public;

    var
        TraceMgt: Codeunit "PTV Planning Trace Mgt";

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Inventory Profile Offsetting", OnBeforeCalculatePlanFromWorksheet2, '', false, false)]
    local procedure ClearCacheBeforePlan(var Item: Record Item; TemplateName: Code[10]; WorksheetName: Code[10]; OrderDate: Date; ToDate: Date; MRPPlanning: Boolean; RespectPlanningParm: Boolean)
    begin
        TraceMgt.ClearPlanCache();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Inventory Profile Offsetting", OnAfterCalculatePlanFromWorksheet, '', false, false)]
    local procedure ClearCacheAfterPlan(var Item: Record Item)
    begin
        TraceMgt.ClearPlanCache();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Inventory Profile Offsetting", OnAfterForecastInitDemand, '', false, false)]
    local procedure CacheForecast(var InventoryProfile: Record "Inventory Profile"; ProductionForecastEntry: Record "Production Forecast Entry"; ItemNo: Code[20]; LocationCode: Code[10]; TotalForecastQty: Decimal)
    begin
        TraceMgt.CacheForecastDemand(InventoryProfile."Line No.", ProductionForecastEntry."Production Forecast Name", ProductionForecastEntry."Forecast Date", ItemNo);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Plng. Component Invt. Profile", OnAfterTransferInventoryProfileFromPlanningComponent, '', false, false)]
    local procedure CachePlanningComponent(var InventoryProfile: Record "Inventory Profile"; var PlanningComponent: Record "Planning Component")
    begin
        TraceMgt.CacheComponentDemand(InventoryProfile."Line No.", PlanningComponent);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Inventory Profile Offsetting", OnBeforeTrack, '', false, false)]
    local procedure CapturePeg(var FromProfile: Record "Inventory Profile"; var ToProfile: Record "Inventory Profile"; IsSurplus: Boolean; IssueActionMessage: Boolean; Binding: Enum "Reservation Binding")
    var
        SupplyProfile: Record "Inventory Profile";
        DemandProfile: Record "Inventory Profile";
        PeggedQty: Decimal;
    begin
        if IsSurplus then
            exit;
        if FromProfile.IsSupply = ToProfile.IsSupply then
            exit;
        if FromProfile.IsSupply then begin
            SupplyProfile := FromProfile;
            DemandProfile := ToProfile;
        end else begin
            SupplyProfile := ToProfile;
            DemandProfile := FromProfile;
        end;
        PeggedQty := TraceOverlap(SupplyProfile, DemandProfile);
        TraceMgt.RecordPeg(SupplyProfile, DemandProfile, PeggedQty);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Inventory Profile Offsetting", OnMaintainPlanningLineOnBeforeReqLineInsert, '', false, false)]
    local procedure StampReqLine(var RequisitionLine: Record "Requisition Line"; var SupplyInvtProfile: Record "Inventory Profile"; PlanToDate: Date; CurrentForecast: Code[10]; NewPhase: Option " ","Line Created","Routing Created",Exploded,Obsolete; Direction: Option Forward,Backward; var DemandInvtProfile: Record "Inventory Profile"; ExcludeForecastBefore: Date)
    begin
        TraceMgt.StampRequisitionLine(RequisitionLine, SupplyInvtProfile, DemandInvtProfile, CurrentForecast);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Inventory Profile Offsetting", OnMaintainPlanningLineOnAfterReqLineInsert, '', false, false)]
    local procedure WriteReqLineTrace(var RequisitionLine: Record "Requisition Line")
    begin
        TraceMgt.WriteTraceEntries(RequisitionLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Mfg. Carry Out Action", OnInsertProdOrderOnAfterProdOrderInsert, '', false, false)]
    local procedure HandOffHeader(var ProdOrder: Record "Production Order"; ReqLine: Record "Requisition Line")
    begin
        TraceMgt.HandOffProdOrderHeader(ProdOrder, ReqLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Mfg. Carry Out Action", OnAfterInsertProdOrderLine, '', false, false)]
    local procedure HandOffLine(ReqLine: Record "Requisition Line"; ProdOrder: Record "Production Order"; var ProdOrderLine: Record "Prod. Order Line"; Item: Record Item)
    begin
        TraceMgt.HandOffProdOrderLine(ProdOrder, ProdOrderLine, ReqLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Prod. Order Status Management", OnAfterChangeStatusOnProdOrder, '', false, false)]
    local procedure HandOffStatusChange(var ProdOrder: Record "Production Order"; var ToProdOrder: Record "Production Order"; NewStatus: Enum "Production Order Status"; NewPostingDate: Date; NewUpdateUnitCost: Boolean; var SuppressCommit: Boolean; xProductionOrder: Record "Production Order")
    begin
        TraceMgt.HandOffStatus(ProdOrder, ToProdOrder);
    end;

    local procedure TraceOverlap(SupplyProfile: Record "Inventory Profile"; DemandProfile: Record "Inventory Profile"): Decimal
    var
        SupplyQty: Decimal;
        DemandQty: Decimal;
    begin
        SupplyQty := SupplyProfile."Remaining Quantity (Base)";
        if SupplyQty < 0 then
            SupplyQty := -SupplyQty;
        DemandQty := DemandProfile."Remaining Quantity (Base)";
        if DemandQty < 0 then
            DemandQty := -DemandQty;
        if (SupplyQty = 0) or (DemandQty = 0) then
            exit(0);
        if SupplyQty < DemandQty then
            exit(SupplyQty);
        exit(DemandQty);
    end;
}
