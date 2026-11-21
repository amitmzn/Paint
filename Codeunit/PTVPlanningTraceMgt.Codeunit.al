/// <summary>
/// Pegs forecast, planning worksheet, and production order supply across BOM levels.
/// </summary>
codeunit 76330 "PTV Planning Trace Mgt"
{
    SingleInstance = true;
    Access = Public;

    var
        ForecastCache: Record "PTV Planning Trace Node" temporary;
        ComponentCache: Record "PTV Planning Trace Node" temporary;
        PegBuffer: Record "PTV Planning Trace Entry" temporary;
        LastSupplyProfileLineNo: Integer;
        NextPegNo: Integer;

    /// <summary>
    /// Clears the in-memory forecast, component, and peg cache for the current plan run.
    /// </summary>
    procedure ClearPlanCache()
    begin
        ForecastCache.Reset();
        ForecastCache.DeleteAll();
        ComponentCache.Reset();
        ComponentCache.DeleteAll();
        PegBuffer.Reset();
        PegBuffer.DeleteAll();
        LastSupplyProfileLineNo := 0;
        NextPegNo := 0;
    end;

    /// <summary>
    /// Remembers the forecast entry behind a demand profile line.
    /// </summary>
    procedure CacheForecastDemand(ProfileLineNo: Integer; ForecastName: Code[10]; ForecastDate: Date; ItemNo: Code[20])
    begin
        if ProfileLineNo = 0 then
            exit;
        if ForecastCache.Get(ProfileLineNo) then begin
            ForecastCache."Document No." := ForecastName;
            ForecastCache."Forecast Date" := ForecastDate;
            ForecastCache."Item No." := ItemNo;
            ForecastCache.Modify();
        end else begin
            ForecastCache.Init();
            ForecastCache."Entry No." := ProfileLineNo;
            ForecastCache."Profile Line No." := ProfileLineNo;
            ForecastCache."Document No." := ForecastName;
            ForecastCache."Forecast Date" := ForecastDate;
            ForecastCache."Item No." := ItemNo;
            ForecastCache.Insert();
        end;
    end;

    /// <summary>
    /// Remembers the parent requisition line of a planning-component demand profile.
    /// </summary>
    procedure CacheComponentDemand(ProfileLineNo: Integer; PlanningComponent: Record "Planning Component")
    begin
        if ProfileLineNo = 0 then
            exit;
        if ComponentCache.Get(ProfileLineNo) then begin
            CopyComponent(ComponentCache, PlanningComponent);
            ComponentCache.Modify();
        end else begin
            ComponentCache.Init();
            ComponentCache."Entry No." := ProfileLineNo;
            ComponentCache."Profile Line No." := ProfileLineNo;
            CopyComponent(ComponentCache, PlanningComponent);
            ComponentCache.Insert();
        end;
    end;

    /// <summary>
    /// Records one supply-to-demand peg before planning reduces the profile quantities.
    /// </summary>
    procedure RecordPeg(SupplyProfile: Record "Inventory Profile"; DemandProfile: Record "Inventory Profile"; PeggedQty: Decimal)
    begin
        if PeggedQty = 0 then
            exit;
        if SupplyProfile."Line No." = 0 then
            exit;
        InsertPeg(SupplyProfile, DemandProfile, PeggedQty, '');
    end;

    /// <summary>
    /// Copies root and parent references onto a requisition line before it is inserted.
    /// </summary>
    procedure StampRequisitionLine(var RequisitionLine: Record "Requisition Line"; SupplyProfile: Record "Inventory Profile"; DemandProfile: Record "Inventory Profile"; CurrentForecast: Code[10])
    var
        PegCount: Integer;
    begin
        LastSupplyProfileLineNo := 0;
        if not IsManufacturingSupply(RequisitionLine) then
            exit;
        if RequisitionLine."Action Message" = RequisitionLine."Action Message"::Cancel then
            exit;

        EnsurePeg(SupplyProfile, DemandProfile, CurrentForecast);
        PegBuffer.Reset();
        PegBuffer.SetRange("Supply Profile Line No.", SupplyProfile."Line No.");
        PegCount := PegBuffer.Count();
        if PegCount = 0 then
            exit;
        PegBuffer.FindFirst();
        ApplyPegToRequisitionLine(RequisitionLine, PegBuffer, PegCount > 1);
        if (RequisitionLine."PTV Root FG Item No." = '') and (RequisitionLine."PTV Parent Source Type" = RequisitionLine."PTV Parent Source Type"::"Demand Forecast") then
            RequisitionLine."PTV Root FG Item No." := RequisitionLine."No.";
        LastSupplyProfileLineNo := SupplyProfile."Line No.";
    end;

    /// <summary>
    /// Writes one ledger row for each peg of the requisition line that was just inserted.
    /// </summary>
    procedure WriteTraceEntries(RequisitionLine: Record "Requisition Line")
    begin
        if LastSupplyProfileLineNo = 0 then
            exit;
        PegBuffer.Reset();
        PegBuffer.SetRange("Supply Profile Line No.", LastSupplyProfileLineNo);
        if PegBuffer.FindSet() then
            repeat
                InsertTraceEntry(RequisitionLine, PegBuffer);
            until PegBuffer.Next() = 0;
        PegBuffer.DeleteAll();
        PegBuffer.Reset();
        LastSupplyProfileLineNo := 0;
    end;

    /// <summary>
    /// Copies traceability onto a new production order and retargets dependents still pointing at the requisition line.
    /// </summary>
    procedure HandOffProdOrderHeader(var ProdOrder: Record "Production Order"; ReqLine: Record "Requisition Line")
    begin
        CopyReqLineToProdOrder(ProdOrder, ReqLine);
        ProdOrder.Modify(false);
        RetargetFromReqLine(ReqLine, ProdOrder);
    end;

    /// <summary>
    /// Copies traceability onto the production order line created from the requisition line.
    /// </summary>
    procedure HandOffProdOrderLine(ProdOrder: Record "Production Order"; var ProdOrderLine: Record "Prod. Order Line"; ReqLine: Record "Requisition Line")
    var
        Trace: Record "PTV Planning Trace Entry";
    begin
        CopyProdOrderToLine(ProdOrderLine, ProdOrder, ReqLine);
        ProdOrderLine.Modify(false);

        Trace.SetRange("Child Document Type", SourceTypeFromProdOrder(ProdOrder));
        Trace.SetRange("Child Document No.", ProdOrder."No.");
        Trace.SetRange("Child Line No.", 0);
        Trace.SetRange("Item No.", ProdOrderLine."Item No.");
        if Trace.FindSet(true) then
            repeat
                Trace."Child Line No." := ProdOrderLine."Line No.";
                Trace.Modify(true);
            until Trace.Next() = 0;
    end;

    /// <summary>
    /// Keeps child references aligned when a production order changes status and keeps the same order number.
    /// </summary>
    procedure HandOffStatus(FromProdOrder: Record "Production Order"; var ToProdOrder: Record "Production Order")
    var
        OldType: Enum "PTV Planning Source Type";
        NewType: Enum "PTV Planning Source Type";
    begin
        if ToProdOrder."PTV Root Demand Forecast" = '' then
            ToProdOrder."PTV Root Demand Forecast" := FromProdOrder."PTV Root Demand Forecast";
        if ToProdOrder."PTV Root FG Item No." = '' then
            ToProdOrder."PTV Root FG Item No." := FromProdOrder."PTV Root FG Item No.";
        if ToProdOrder."PTV Root FG Prod. Order No." = '' then
            ToProdOrder."PTV Root FG Prod. Order No." := FromProdOrder."PTV Root FG Prod. Order No.";
        if ToProdOrder."PTV Parent Source No." = '' then begin
            ToProdOrder."PTV Parent Source Type" := FromProdOrder."PTV Parent Source Type";
            ToProdOrder."PTV Parent Source No." := FromProdOrder."PTV Parent Source No.";
            ToProdOrder."PTV Parent Source Line No." := FromProdOrder."PTV Parent Source Line No.";
            ToProdOrder."PTV Parent Wksh. Template" := FromProdOrder."PTV Parent Wksh. Template";
            ToProdOrder."PTV Parent Wksh. Batch Name" := FromProdOrder."PTV Parent Wksh. Batch Name";
            ToProdOrder."PTV Multiple Parents" := FromProdOrder."PTV Multiple Parents";
        end;
        ToProdOrder.Modify(false);

        OldType := SourceTypeFromProdOrder(FromProdOrder);
        NewType := SourceTypeFromProdOrder(ToProdOrder);
        if (OldType = NewType) or (OldType = OldType::" ") or (NewType = NewType::" ") then
            exit;
        RewriteDocumentType(OldType, NewType, ToProdOrder."No.");
    end;

    /// <summary>
    /// Opens the traceability tree for a planning worksheet line.
    /// </summary>
    procedure OpenTreeForRequisitionLine(ReqLine: Record "Requisition Line")
    var
        Tree: Page "PTV Planning Trace Tree";
    begin
        Tree.SetRoot(ReqLine."PTV Root Demand Forecast", ReqLine."PTV Root FG Item No.", ReqLine."PTV Root FG Prod. Order No.");
        Tree.Run();
    end;

    /// <summary>
    /// Opens the traceability tree for a production order.
    /// </summary>
    procedure OpenTreeForProdOrder(ProdOrder: Record "Production Order")
    var
        Tree: Page "PTV Planning Trace Tree";
    begin
        Tree.SetRoot(ProdOrder."PTV Root Demand Forecast", ProdOrder."PTV Root FG Item No.", ProdOrder."PTV Root FG Prod. Order No.");
        Tree.Run();
    end;

    /// <summary>
    /// Fills a temporary tree from the ledger for one root forecast and finished-good item.
    /// </summary>
    procedure BuildTree(var Node: Record "PTV Planning Trace Node" temporary; RootForecast: Code[20]; RootItemNo: Code[20]; RootOrderNo: Code[20])
    var
        Seen: Record "PTV Planning Trace Node" temporary;
        NextNo: Integer;
    begin
        if not Node.IsTemporary then
            exit;
        Node.Reset();
        Node.DeleteAll();
        if (RootForecast = '') and (RootItemNo = '') and (RootOrderNo = '') then
            exit;

        if RootForecast <> '' then begin
            AddNode(Node, NextNo, 0, StrSubstNo('Demand Forecast %1', RootForecast), Enum::"PTV Planning Source Type"::"Demand Forecast", RootForecast, 0, RootItemNo, '', 0, 0, '', '');
            AddChildren(Node, Seen, NextNo, Enum::"PTV Planning Source Type"::"Demand Forecast", RootForecast, 0, '', '', 1, RootForecast, RootItemNo);
            exit;
        end;

        AddNode(Node, NextNo, 0, StrSubstNo('%1 %2', RootItemNo, RootOrderNo), SourceTypeForOrderNo(RootOrderNo), RootOrderNo, 0, RootItemNo, '', 0, 0, '', '');
        if RootOrderNo <> '' then
            AddChildren(Node, Seen, NextNo, SourceTypeForOrderNo(RootOrderNo), RootOrderNo, 0, '', '', 1, RootForecast, RootItemNo);
    end;

    local procedure InsertPeg(SupplyProfile: Record "Inventory Profile"; DemandProfile: Record "Inventory Profile"; PeggedQty: Decimal; CurrentForecast: Code[10])
    begin
        NextPegNo += 1;
        PegBuffer.Init();
        PegBuffer."Entry No." := NextPegNo;
        PegBuffer."Supply Profile Line No." := SupplyProfile."Line No.";
        PegBuffer."Pegged Quantity" := PeggedQty;
        PegBuffer."Item No." := SupplyProfile."Item No.";
        PegBuffer."Variant Code" := SupplyProfile."Variant Code";
        PegBuffer."BOM Level" := SupplyProfile."Planning Level Code";
        FillParentFromDemand(PegBuffer, DemandProfile, CurrentForecast);
        if PegBuffer."Root FG Item No." = '' then
            PegBuffer."Root FG Item No." := SupplyProfile."Item No.";
        if PegBuffer."BOM Level" = 0 then
            PegBuffer."BOM Level" := DemandProfile."Planning Level Code";
        PegBuffer.Insert();
    end;

    local procedure EnsurePeg(SupplyProfile: Record "Inventory Profile"; DemandProfile: Record "Inventory Profile"; CurrentForecast: Code[10])
    var
        PeggedQty: Decimal;
    begin
        PegBuffer.Reset();
        PegBuffer.SetRange("Supply Profile Line No.", SupplyProfile."Line No.");
        if not PegBuffer.IsEmpty() then begin
            PegBuffer.Reset();
            exit;
        end;
        PegBuffer.Reset();
        PeggedQty := OverlapQty(SupplyProfile, DemandProfile);
        if PeggedQty = 0 then
            PeggedQty := SupplyProfile."Quantity (Base)";
        if PeggedQty < 0 then
            PeggedQty := -PeggedQty;
        if (DemandProfile."Line No." = 0) and (CurrentForecast = '') then
            exit;
        InsertPeg(SupplyProfile, DemandProfile, PeggedQty, CurrentForecast);
    end;

    local procedure FillParentFromDemand(var Peg: Record "PTV Planning Trace Entry"; DemandProfile: Record "Inventory Profile"; CurrentForecast: Code[10])
    begin
        case DemandProfile."Source Type" of
            Database::"Production Forecast Entry":
                FillForecastParent(Peg, DemandProfile, CurrentForecast);
            Database::"Planning Component":
                FillComponentParent(Peg, DemandProfile);
            Database::"Prod. Order Component", Database::"Prod. Order Line":
                FillProdOrderParent(Peg, DemandProfile);
            else
                if CurrentForecast <> '' then
                    FillForecastParent(Peg, DemandProfile, CurrentForecast)
                else
                    if ComponentCache.Get(DemandProfile."Line No.") then
                        FillComponentParent(Peg, DemandProfile);
        end;
    end;

    local procedure FillForecastParent(var Peg: Record "PTV Planning Trace Entry"; DemandProfile: Record "Inventory Profile"; CurrentForecast: Code[10])
    var
        ForecastName: Code[20];
        ForecastDate: Date;
    begin
        ForecastName := CurrentForecast;
        ForecastDate := DemandProfile."Due Date";
        if ForecastCache.Get(DemandProfile."Line No.") then begin
            ForecastName := ForecastCache."Document No.";
            ForecastDate := ForecastCache."Forecast Date";
            if Peg."Root FG Item No." = '' then
                Peg."Root FG Item No." := ForecastCache."Item No.";
        end else
            if DemandProfile."Source ID" <> '' then
                ForecastName := CopyStr(DemandProfile."Source ID", 1, MaxStrLen(ForecastName));
        if (ForecastName = '') and (CurrentForecast <> '') then
            ForecastName := CurrentForecast;
        Peg."Root Forecast Name" := ForecastName;
        Peg."Root Forecast Date" := ForecastDate;
        if Peg."Root FG Item No." = '' then
            Peg."Root FG Item No." := DemandProfile."Item No.";
        Peg."Parent Document Type" := Peg."Parent Document Type"::"Demand Forecast";
        Peg."Parent Document No." := ForecastName;
        Peg."Parent Line No." := 0;
    end;

    local procedure FillComponentParent(var Peg: Record "PTV Planning Trace Entry"; DemandProfile: Record "Inventory Profile")
    var
        ParentReqLine: Record "Requisition Line";
        PlanningComponent: Record "Planning Component";
        ParentTrace: Record "PTV Planning Trace Entry";
        TemplateName: Code[10];
        BatchName: Code[10];
        WorksheetLineNo: Integer;
    begin
        if ComponentCache.Get(DemandProfile."Line No.") then begin
            TemplateName := ComponentCache."Worksheet Template Name";
            BatchName := ComponentCache."Journal Batch Name";
            WorksheetLineNo := ComponentCache."Parent Line No.";
        end else begin
            TemplateName := CopyStr(DemandProfile."Source ID", 1, MaxStrLen(TemplateName));
            BatchName := DemandProfile."Source Batch Name";
            if DemandProfile."Source Prod. Order Line" <> 0 then
                WorksheetLineNo := DemandProfile."Source Prod. Order Line";
            PlanningComponent.SetRange("Worksheet Template Name", TemplateName);
            PlanningComponent.SetRange("Worksheet Batch Name", BatchName);
            if WorksheetLineNo <> 0 then
                PlanningComponent.SetRange("Worksheet Line No.", WorksheetLineNo);
            PlanningComponent.SetRange("Line No.", DemandProfile."Source Ref. No.");
            if PlanningComponent.FindFirst() then
                WorksheetLineNo := PlanningComponent."Worksheet Line No."
            else begin
                PlanningComponent.SetRange("Line No.");
                if WorksheetLineNo <> 0 then
                    PlanningComponent.SetRange("Worksheet Line No.", WorksheetLineNo)
                else
                    PlanningComponent.SetRange("Worksheet Line No.", DemandProfile."Source Ref. No.");
                if PlanningComponent.FindFirst() then
                    WorksheetLineNo := PlanningComponent."Worksheet Line No.";
            end;
        end;

        ParentReqLine.SetRange("Worksheet Template Name", TemplateName);
        ParentReqLine.SetRange("Journal Batch Name", BatchName);
        ParentReqLine.SetRange("Line No.", WorksheetLineNo);
        if ParentReqLine.FindFirst() then begin
            Peg."Root Forecast Name" := ParentReqLine."PTV Root Demand Forecast";
            Peg."Root FG Item No." := ParentReqLine."PTV Root FG Item No.";
            Peg."Root FG Order No." := ParentReqLine."PTV Root FG Prod. Order No.";
            Peg."Parent Document No." := ParentReqLine."No.";
            if Peg."Root FG Item No." = '' then
                Peg."Root FG Item No." := ParentReqLine."No.";
        end;

        ParentTrace.SetRange("Child Document Type", ParentTrace."Child Document Type"::"Planning Worksheet");
        ParentTrace.SetRange("Child Wksh. Template Name", TemplateName);
        ParentTrace.SetRange("Child Wksh. Batch Name", BatchName);
        ParentTrace.SetRange("Child Line No.", WorksheetLineNo);
        if ParentTrace.FindFirst() then begin
            if Peg."Root Forecast Name" = '' then
                Peg."Root Forecast Name" := ParentTrace."Root Forecast Name";
            Peg."Root Forecast Date" := ParentTrace."Root Forecast Date";
            if Peg."Root FG Item No." = '' then
                Peg."Root FG Item No." := ParentTrace."Root FG Item No.";
            if Peg."Root FG Order No." = '' then
                Peg."Root FG Order No." := ParentTrace."Root FG Order No.";
        end;

        Peg."Parent Document Type" := Peg."Parent Document Type"::"Planning Worksheet";
        Peg."Parent Line No." := WorksheetLineNo;
        Peg."Parent Wksh. Template Name" := TemplateName;
        Peg."Parent Wksh. Batch Name" := BatchName;
        if Peg."BOM Level" = 0 then
            Peg."BOM Level" := DemandProfile."Planning Level Code" + 1;
    end;

    local procedure FillProdOrderParent(var Peg: Record "PTV Planning Trace Entry"; DemandProfile: Record "Inventory Profile")
    var
        ProdOrder: Record "Production Order";
        OrderNo: Code[20];
    begin
        OrderNo := DemandProfile."Source ID";
        if OrderNo = '' then
            OrderNo := DemandProfile."Primary Order No.";
        ProdOrder.SetRange("No.", OrderNo);
        if not ProdOrder.FindFirst() then
            exit;
        Peg."Parent Document Type" := SourceTypeFromProdOrder(ProdOrder);
        Peg."Parent Document No." := ProdOrder."No.";
        Peg."Parent Line No." := DemandProfile."Source Prod. Order Line";
        Peg."Root Forecast Name" := ProdOrder."PTV Root Demand Forecast";
        Peg."Root FG Item No." := ProdOrder."PTV Root FG Item No.";
        Peg."Root FG Order No." := ProdOrder."PTV Root FG Prod. Order No.";
        if Peg."Root FG Item No." = '' then begin
            Peg."Root FG Item No." := ProdOrder."Source No.";
            Peg."Root FG Order No." := ProdOrder."No.";
        end;
    end;

    local procedure ApplyPegToRequisitionLine(var RequisitionLine: Record "Requisition Line"; Peg: Record "PTV Planning Trace Entry"; MultipleParents: Boolean)
    begin
        RequisitionLine."PTV Root Demand Forecast" := Peg."Root Forecast Name";
        RequisitionLine."PTV Root FG Item No." := Peg."Root FG Item No.";
        RequisitionLine."PTV Root FG Prod. Order No." := Peg."Root FG Order No.";
        RequisitionLine."PTV Parent Source Type" := Peg."Parent Document Type";
        RequisitionLine."PTV Parent Source No." := Peg."Parent Document No.";
        RequisitionLine."PTV Parent Source Line No." := Peg."Parent Line No.";
        RequisitionLine."PTV Parent Wksh. Template" := Peg."Parent Wksh. Template Name";
        RequisitionLine."PTV Parent Wksh. Batch Name" := Peg."Parent Wksh. Batch Name";
        RequisitionLine."PTV Multiple Parents" := MultipleParents;
    end;

    local procedure InsertTraceEntry(RequisitionLine: Record "Requisition Line"; Peg: Record "PTV Planning Trace Entry")
    var
        Trace: Record "PTV Planning Trace Entry";
    begin
        Trace.Init();
        Trace."Entry No." := NextEntryNo();
        Trace."Root Forecast Name" := Peg."Root Forecast Name";
        Trace."Root Forecast Date" := Peg."Root Forecast Date";
        Trace."Root FG Item No." := RequisitionLine."PTV Root FG Item No.";
        if Trace."Root FG Item No." = '' then
            Trace."Root FG Item No." := Peg."Root FG Item No.";
        Trace."Root FG Order No." := RequisitionLine."PTV Root FG Prod. Order No.";
        Trace."Parent Document Type" := Peg."Parent Document Type";
        Trace."Parent Document No." := Peg."Parent Document No.";
        Trace."Parent Line No." := Peg."Parent Line No.";
        Trace."Parent Wksh. Template Name" := Peg."Parent Wksh. Template Name";
        Trace."Parent Wksh. Batch Name" := Peg."Parent Wksh. Batch Name";
        Trace."Child Document Type" := Trace."Child Document Type"::"Planning Worksheet";
        Trace."Child Document No." := RequisitionLine."No.";
        Trace."Child Line No." := RequisitionLine."Line No.";
        Trace."Child Wksh. Template Name" := RequisitionLine."Worksheet Template Name";
        Trace."Child Wksh. Batch Name" := RequisitionLine."Journal Batch Name";
        Trace."Item No." := RequisitionLine."No.";
        Trace."Variant Code" := RequisitionLine."Variant Code";
        Trace."Pegged Quantity" := Peg."Pegged Quantity";
        Trace."BOM Level" := RequisitionLine."Planning Level";
        if Trace."BOM Level" = 0 then
            Trace."BOM Level" := Peg."BOM Level";
        Trace."Created DateTime" := CurrentDateTime();
        Trace.Insert(true);
    end;

    local procedure CopyReqLineToProdOrder(var ProdOrder: Record "Production Order"; ReqLine: Record "Requisition Line")
    begin
        ProdOrder."PTV Root Demand Forecast" := ReqLine."PTV Root Demand Forecast";
        ProdOrder."PTV Root FG Item No." := ReqLine."PTV Root FG Item No.";
        if ProdOrder."PTV Root FG Item No." = '' then
            ProdOrder."PTV Root FG Item No." := ReqLine."No.";
        ProdOrder."PTV Parent Source Type" := ReqLine."PTV Parent Source Type";
        ProdOrder."PTV Parent Source No." := ReqLine."PTV Parent Source No.";
        ProdOrder."PTV Parent Source Line No." := ReqLine."PTV Parent Source Line No.";
        ProdOrder."PTV Parent Wksh. Template" := ReqLine."PTV Parent Wksh. Template";
        ProdOrder."PTV Parent Wksh. Batch Name" := ReqLine."PTV Parent Wksh. Batch Name";
        ProdOrder."PTV Multiple Parents" := ReqLine."PTV Multiple Parents";
        if IsRootProdOrder(ProdOrder, ProdOrder."PTV Root FG Item No.") or (ReqLine."No." = ReqLine."PTV Root FG Item No.") or (ReqLine."PTV Root FG Item No." = '') then
            ProdOrder."PTV Root FG Prod. Order No." := ProdOrder."No."
        else
            ProdOrder."PTV Root FG Prod. Order No." := ReqLine."PTV Root FG Prod. Order No.";
    end;

    local procedure CopyProdOrderToLine(var ProdOrderLine: Record "Prod. Order Line"; ProdOrder: Record "Production Order"; ReqLine: Record "Requisition Line")
    begin
        ProdOrderLine."PTV Root Demand Forecast" := ProdOrder."PTV Root Demand Forecast";
        if ProdOrderLine."PTV Root Demand Forecast" = '' then
            ProdOrderLine."PTV Root Demand Forecast" := ReqLine."PTV Root Demand Forecast";
        ProdOrderLine."PTV Root FG Item No." := ProdOrder."PTV Root FG Item No.";
        ProdOrderLine."PTV Root FG Prod. Order No." := ProdOrder."PTV Root FG Prod. Order No.";
        ProdOrderLine."PTV Parent Source Type" := ProdOrder."PTV Parent Source Type";
        ProdOrderLine."PTV Parent Source No." := ProdOrder."PTV Parent Source No.";
        ProdOrderLine."PTV Parent Source Line No." := ProdOrder."PTV Parent Source Line No.";
        ProdOrderLine."PTV Parent Wksh. Template" := ProdOrder."PTV Parent Wksh. Template";
        ProdOrderLine."PTV Parent Wksh. Batch Name" := ProdOrder."PTV Parent Wksh. Batch Name";
        ProdOrderLine."PTV Multiple Parents" := ProdOrder."PTV Multiple Parents";
    end;

    local procedure RetargetFromReqLine(ReqLine: Record "Requisition Line"; ProdOrder: Record "Production Order")
    var
        ChildKeys: Record "PTV Planning Trace Entry" temporary;
        NewType: Enum "PTV Planning Source Type";
    begin
        NewType := SourceTypeFromProdOrder(ProdOrder);
        UpdateChildPointer(ReqLine, ProdOrder, NewType);
        CollectParentChildren(ReqLine, ChildKeys);
        UpdateParentPointer(ReqLine, ProdOrder, NewType);
        RefreshChildren(ChildKeys);
    end;

    local procedure UpdateChildPointer(ReqLine: Record "Requisition Line"; ProdOrder: Record "Production Order"; NewType: Enum "PTV Planning Source Type")
    var
        Trace: Record "PTV Planning Trace Entry";
    begin
        ApplyChildReqFilter(Trace, ReqLine);
        if Trace.FindSet(true) then
            repeat
                Trace."Child Document Type" := NewType;
                Trace."Child Document No." := ProdOrder."No.";
                Trace."Child Line No." := 0;
                Trace."Child Wksh. Template Name" := '';
                Trace."Child Wksh. Batch Name" := '';
                if IsRootProdOrder(ProdOrder, Trace."Root FG Item No.") then
                    Trace."Root FG Order No." := ProdOrder."No.";
                Trace.Modify(true);
            until Trace.Next() = 0;
    end;

    local procedure UpdateParentPointer(ReqLine: Record "Requisition Line"; ProdOrder: Record "Production Order"; NewType: Enum "PTV Planning Source Type")
    var
        Trace: Record "PTV Planning Trace Entry";
    begin
        ApplyParentReqFilter(Trace, ReqLine);
        if Trace.FindSet(true) then
            repeat
                Trace."Parent Document Type" := NewType;
                Trace."Parent Document No." := ProdOrder."No.";
                Trace."Parent Line No." := 0;
                Trace."Parent Wksh. Template Name" := '';
                Trace."Parent Wksh. Batch Name" := '';
                if IsRootProdOrder(ProdOrder, Trace."Root FG Item No.") then
                    Trace."Root FG Order No." := ProdOrder."No.";
                Trace.Modify(true);
            until Trace.Next() = 0;
    end;

    local procedure CollectParentChildren(ReqLine: Record "Requisition Line"; var ChildKeys: Record "PTV Planning Trace Entry" temporary)
    var
        Trace: Record "PTV Planning Trace Entry";
    begin
        ApplyParentReqFilter(Trace, ReqLine);
        if Trace.FindSet() then
            repeat
                ChildKeys.Init();
                ChildKeys."Entry No." := Trace."Entry No.";
                ChildKeys."Child Document Type" := Trace."Child Document Type";
                ChildKeys."Child Document No." := Trace."Child Document No.";
                ChildKeys."Child Line No." := Trace."Child Line No.";
                ChildKeys."Child Wksh. Template Name" := Trace."Child Wksh. Template Name";
                ChildKeys."Child Wksh. Batch Name" := Trace."Child Wksh. Batch Name";
                if ChildKeys.Insert() then;
            until Trace.Next() = 0;
    end;

    local procedure RefreshChildren(var ChildKeys: Record "PTV Planning Trace Entry" temporary)
    begin
        ChildKeys.Reset();
        if ChildKeys.FindSet() then
            repeat
                if ChildKeys."Child Document Type" = ChildKeys."Child Document Type"::"Planning Worksheet" then
                    RefreshReqLine(ChildKeys)
                else
                    RefreshProdOrders(ChildKeys."Child Document No.");
            until ChildKeys.Next() = 0;
    end;

    local procedure RefreshReqLine(ChildKey: Record "PTV Planning Trace Entry")
    var
        ReqLine: Record "Requisition Line";
        Trace: Record "PTV Planning Trace Entry";
        PegCount: Integer;
    begin
        ReqLine.SetRange("Worksheet Template Name", ChildKey."Child Wksh. Template Name");
        ReqLine.SetRange("Journal Batch Name", ChildKey."Child Wksh. Batch Name");
        ReqLine.SetRange("Line No.", ChildKey."Child Line No.");
        if not ReqLine.FindFirst() then
            exit;
        ApplyChildReqFilter(Trace, ReqLine);
        PegCount := Trace.Count();
        if PegCount = 0 then
            exit;
        Trace.FindFirst();
        ApplyPegToRequisitionLine(ReqLine, Trace, PegCount > 1);
        if Trace."Root FG Order No." <> '' then
            ReqLine."PTV Root FG Prod. Order No." := Trace."Root FG Order No.";
        ReqLine.Modify(false);
    end;

    local procedure RefreshProdOrders(OrderNo: Code[20])
    var
        ProdOrder: Record "Production Order";
        Trace: Record "PTV Planning Trace Entry";
        PegCount: Integer;
    begin
        if OrderNo = '' then
            exit;
        ProdOrder.SetRange("No.", OrderNo);
        if ProdOrder.FindSet(true) then
            repeat
                Trace.SetRange("Child Document No.", ProdOrder."No.");
                Trace.SetFilter("Child Document Type", '%1|%2|%3', Trace."Child Document Type"::"Planned Prod. Order", Trace."Child Document Type"::"Firm Planned Prod. Order", Trace."Child Document Type"::"Released Prod. Order");
                PegCount := Trace.Count();
                if PegCount > 0 then begin
                    Trace.FindFirst();
                    ProdOrder."PTV Root Demand Forecast" := Trace."Root Forecast Name";
                    ProdOrder."PTV Root FG Item No." := Trace."Root FG Item No.";
                    ProdOrder."PTV Root FG Prod. Order No." := Trace."Root FG Order No.";
                    ProdOrder."PTV Parent Source Type" := Trace."Parent Document Type";
                    ProdOrder."PTV Parent Source No." := Trace."Parent Document No.";
                    ProdOrder."PTV Parent Source Line No." := Trace."Parent Line No.";
                    ProdOrder."PTV Parent Wksh. Template" := Trace."Parent Wksh. Template Name";
                    ProdOrder."PTV Parent Wksh. Batch Name" := Trace."Parent Wksh. Batch Name";
                    ProdOrder."PTV Multiple Parents" := PegCount > 1;
                    ProdOrder.Modify(false);
                end;
                Trace.Reset();
            until ProdOrder.Next() = 0;
    end;

    local procedure RewriteDocumentType(OldType: Enum "PTV Planning Source Type"; NewType: Enum "PTV Planning Source Type"; OrderNo: Code[20])
    var
        Trace: Record "PTV Planning Trace Entry";
        ReqLine: Record "Requisition Line";
        ProdOrder: Record "Production Order";
        ProdOrderLine: Record "Prod. Order Line";
    begin
        Trace.SetRange("Parent Document Type", OldType);
        Trace.SetRange("Parent Document No.", OrderNo);
        if Trace.FindSet(true) then
            repeat
                Trace."Parent Document Type" := NewType;
                Trace.Modify(true);
            until Trace.Next() = 0;

        Trace.Reset();
        Trace.SetRange("Child Document Type", OldType);
        Trace.SetRange("Child Document No.", OrderNo);
        if Trace.FindSet(true) then
            repeat
                Trace."Child Document Type" := NewType;
                Trace.Modify(true);
            until Trace.Next() = 0;

        ReqLine.SetRange("PTV Parent Source Type", OldType);
        ReqLine.SetRange("PTV Parent Source No.", OrderNo);
        if ReqLine.FindSet(true) then
            repeat
                ReqLine."PTV Parent Source Type" := NewType;
                ReqLine.Modify(false);
            until ReqLine.Next() = 0;

        ProdOrder.SetRange("PTV Parent Source Type", OldType);
        ProdOrder.SetRange("PTV Parent Source No.", OrderNo);
        if ProdOrder.FindSet(true) then
            repeat
                ProdOrder."PTV Parent Source Type" := NewType;
                ProdOrder.Modify(false);
            until ProdOrder.Next() = 0;

        ProdOrderLine.SetRange("PTV Parent Source Type", OldType);
        ProdOrderLine.SetRange("PTV Parent Source No.", OrderNo);
        if ProdOrderLine.FindSet(true) then
            repeat
                ProdOrderLine."PTV Parent Source Type" := NewType;
                ProdOrderLine.Modify(false);
            until ProdOrderLine.Next() = 0;
    end;

    local procedure AddChildren(var Node: Record "PTV Planning Trace Node" temporary; var Seen: Record "PTV Planning Trace Node" temporary; var NextNo: Integer; ParentType: Enum "PTV Planning Source Type"; ParentNo: Code[20]; ParentLineNo: Integer; ParentTemplate: Code[10]; ParentBatch: Code[10]; Indent: Integer; RootForecast: Code[20]; RootItemNo: Code[20])
    var
        Trace: Record "PTV Planning Trace Entry";
        Group: Record "PTV Planning Trace Entry" temporary;
    begin
        if not MarkSeen(Seen, ParentType, ParentNo, ParentLineNo, ParentTemplate, ParentBatch) then
            exit;
        Trace.SetRange("Parent Document Type", ParentType);
        Trace.SetRange("Parent Document No.", ParentNo);
        if ParentType = ParentType::"Planning Worksheet" then begin
            Trace.SetRange("Parent Wksh. Template Name", ParentTemplate);
            Trace.SetRange("Parent Wksh. Batch Name", ParentBatch);
            Trace.SetRange("Parent Line No.", ParentLineNo);
        end;
        if RootForecast <> '' then
            Trace.SetRange("Root Forecast Name", RootForecast);
        if RootItemNo <> '' then
            Trace.SetRange("Root FG Item No.", RootItemNo);
        if Trace.FindSet() then
            repeat
                AccumulateChild(Group, Trace);
            until Trace.Next() = 0;

        Group.Reset();
        if Group.FindSet() then
            repeat
                AddNode(Node, NextNo, Indent, ChildNodeText(Group), Group."Child Document Type", Group."Child Document No.", Group."Child Line No.", Group."Item No.", Group."Variant Code", Group."Pegged Quantity", Group."BOM Level", Group."Child Wksh. Template Name", Group."Child Wksh. Batch Name");
                AddChildren(Node, Seen, NextNo, Group."Child Document Type", Group."Child Document No.", Group."Child Line No.", Group."Child Wksh. Template Name", Group."Child Wksh. Batch Name", Indent + 1, RootForecast, RootItemNo);
            until Group.Next() = 0;
    end;

    local procedure AccumulateChild(var Group: Record "PTV Planning Trace Entry" temporary; Trace: Record "PTV Planning Trace Entry")
    begin
        Group.Reset();
        Group.SetRange("Child Document Type", Trace."Child Document Type");
        Group.SetRange("Child Document No.", Trace."Child Document No.");
        Group.SetRange("Child Line No.", Trace."Child Line No.");
        Group.SetRange("Child Wksh. Template Name", Trace."Child Wksh. Template Name");
        Group.SetRange("Child Wksh. Batch Name", Trace."Child Wksh. Batch Name");
        if Group.FindFirst() then begin
            Group."Pegged Quantity" += Trace."Pegged Quantity";
            Group.Modify();
        end else begin
            Group.Init();
            Group := Trace;
            Group.Insert();
        end;
        Group.Reset();
    end;

    local procedure AddNode(var Node: Record "PTV Planning Trace Node" temporary; var NextNo: Integer; Indent: Integer; NodeText: Text[100]; DocType: Enum "PTV Planning Source Type"; DocNo: Code[20]; LineNo: Integer; ItemNo: Code[20]; VariantCode: Code[10]; Qty: Decimal; Level: Integer; TemplateName: Code[10]; BatchName: Code[10])
    begin
        NextNo += 1;
        Node.Init();
        Node."Entry No." := NextNo;
        Node."Node Text" := NodeText;
        Node."Document Type" := DocType;
        Node."Document No." := DocNo;
        Node."Line No." := LineNo;
        Node."Item No." := ItemNo;
        Node."Variant Code" := VariantCode;
        Node.Quantity := Qty;
        Node."BOM Level" := Level;
        Node.Indentation := Indent;
        Node."Worksheet Template Name" := TemplateName;
        Node."Journal Batch Name" := BatchName;
        Node.Insert();
    end;

    local procedure ChildNodeText(Trace: Record "PTV Planning Trace Entry"): Text[100]
    begin
        exit(CopyStr(StrSubstNo('%1 %2  %3', Trace."Child Document Type", Trace."Child Document No.", Trace."Item No."), 1, 100));
    end;

    local procedure MarkSeen(var Seen: Record "PTV Planning Trace Node" temporary; DocType: Enum "PTV Planning Source Type"; DocNo: Code[20]; LineNo: Integer; TemplateName: Code[10]; BatchName: Code[10]): Boolean
    var
        NextSeenNo: Integer;
    begin
        Seen.Reset();
        Seen.SetRange("Document Type", DocType);
        Seen.SetRange("Document No.", DocNo);
        Seen.SetRange("Line No.", LineNo);
        Seen.SetRange("Worksheet Template Name", TemplateName);
        Seen.SetRange("Journal Batch Name", BatchName);
        if not Seen.IsEmpty() then
            exit(false);
        Seen.Reset();
        if Seen.FindLast() then
            NextSeenNo := Seen."Entry No."
        else
            NextSeenNo := 0;
        Seen.Init();
        Seen."Entry No." := NextSeenNo + 1;
        Seen."Document Type" := DocType;
        Seen."Document No." := DocNo;
        Seen."Line No." := LineNo;
        Seen."Worksheet Template Name" := TemplateName;
        Seen."Journal Batch Name" := BatchName;
        Seen.Insert();
        exit(true);
    end;

    local procedure ApplyParentReqFilter(var Trace: Record "PTV Planning Trace Entry"; ReqLine: Record "Requisition Line")
    begin
        Trace.Reset();
        Trace.SetRange("Parent Document Type", Trace."Parent Document Type"::"Planning Worksheet");
        Trace.SetRange("Parent Wksh. Template Name", ReqLine."Worksheet Template Name");
        Trace.SetRange("Parent Wksh. Batch Name", ReqLine."Journal Batch Name");
        Trace.SetRange("Parent Line No.", ReqLine."Line No.");
    end;

    local procedure ApplyChildReqFilter(var Trace: Record "PTV Planning Trace Entry"; ReqLine: Record "Requisition Line")
    begin
        Trace.Reset();
        Trace.SetRange("Child Document Type", Trace."Child Document Type"::"Planning Worksheet");
        Trace.SetRange("Child Wksh. Template Name", ReqLine."Worksheet Template Name");
        Trace.SetRange("Child Wksh. Batch Name", ReqLine."Journal Batch Name");
        Trace.SetRange("Child Line No.", ReqLine."Line No.");
    end;

    local procedure CopyComponent(var Cache: Record "PTV Planning Trace Node"; PlanningComponent: Record "Planning Component")
    begin
        Cache."Worksheet Template Name" := PlanningComponent."Worksheet Template Name";
        Cache."Journal Batch Name" := PlanningComponent."Worksheet Batch Name";
        Cache."Parent Line No." := PlanningComponent."Worksheet Line No.";
        Cache."Line No." := PlanningComponent."Line No.";
        Cache."Item No." := PlanningComponent."Item No.";
        Cache."Variant Code" := PlanningComponent."Variant Code";
    end;

    local procedure IsManufacturingSupply(RequisitionLine: Record "Requisition Line"): Boolean
    begin
        if RequisitionLine."Replenishment System" in [RequisitionLine."Replenishment System"::Transfer, RequisitionLine."Replenishment System"::Assembly] then
            exit(false);
        exit(true);
    end;

    local procedure IsRootProdOrder(ProdOrder: Record "Production Order"; RootItemNo: Code[20]): Boolean
    begin
        exit((RootItemNo <> '') and (ProdOrder."Source No." = RootItemNo));
    end;

    local procedure SourceTypeFromProdOrder(ProdOrder: Record "Production Order"): Enum "PTV Planning Source Type"
    begin
        case ProdOrder.Status of
            ProdOrder.Status::Planned:
                exit(Enum::"PTV Planning Source Type"::"Planned Prod. Order");
            ProdOrder.Status::"Firm Planned":
                exit(Enum::"PTV Planning Source Type"::"Firm Planned Prod. Order");
            ProdOrder.Status::Released:
                exit(Enum::"PTV Planning Source Type"::"Released Prod. Order");
            else
                exit(Enum::"PTV Planning Source Type"::" ");
        end;
    end;

    local procedure SourceTypeForOrderNo(OrderNo: Code[20]): Enum "PTV Planning Source Type"
    var
        ProdOrder: Record "Production Order";
    begin
        if OrderNo = '' then
            exit(Enum::"PTV Planning Source Type"::" ");
        ProdOrder.SetRange("No.", OrderNo);
        if ProdOrder.FindFirst() then
            exit(SourceTypeFromProdOrder(ProdOrder));
        exit(Enum::"PTV Planning Source Type"::"Planned Prod. Order");
    end;

    local procedure OverlapQty(SupplyProfile: Record "Inventory Profile"; DemandProfile: Record "Inventory Profile"): Decimal
    var
        SupplyQty: Decimal;
        DemandQty: Decimal;
    begin
        SupplyQty := AbsoluteQty(SupplyProfile."Remaining Quantity (Base)");
        DemandQty := AbsoluteQty(DemandProfile."Remaining Quantity (Base)");
        if (SupplyQty = 0) or (DemandQty = 0) then
            exit(0);
        if SupplyQty < DemandQty then
            exit(SupplyQty);
        exit(DemandQty);
    end;

    local procedure NextEntryNo(): Integer
    var
        Trace: Record "PTV Planning Trace Entry";
    begin
        Trace.LockTable();
        if Trace.FindLast() then
            exit(Trace."Entry No." + 1);
        exit(1);
    end;

    local procedure AbsoluteQty(Value: Decimal): Decimal
    begin
        if Value < 0 then
            exit(-Value);
        exit(Value);
    end;
}
