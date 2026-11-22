#if PTV_TEST
codeunit 76380 "PTV Planning Trace Test"
{
    Subtype = Test;

    var
        Assert: Codeunit Assert;
        TraceMgt: Codeunit "PTV Planning Trace Mgt";
        TemplateTok: Label 'PTV', Locked = true;
        BatchTok: Label 'PLAN', Locked = true;
        ForecastTok: Label 'FC-2026', Locked = true;
        FgItemTok: Label 'PTV-FG', Locked = true;
        FgItem2Tok: Label 'PTV-FG2', Locked = true;
        SfgItemTok: Label 'PTV-SFG', Locked = true;
        FgOrderTok: Label 'PTV-P-FG', Locked = true;
        SfgOrderTok: Label 'PTV-P-SFG', Locked = true;
        CompItemTok: Label 'PTV-COMP', Locked = true;

    [Test]
    procedure ForecastStampsFinishedGoodLine()
    var
        ReqLine: Record "Requisition Line";
        Trace: Record "PTV Planning Trace Entry";
    begin
        Initialize();
        ReqLine := CreateForecastLine(10000, FgItemTok, 10);
        Assert.AreEqual(ForecastTok, ReqLine."PTV Root Demand Forecast", 'Root forecast was not stamped.');
        Assert.AreEqual(FgItemTok, ReqLine."PTV Root FG Item No.", 'Root finished good was not stamped.');
        Assert.AreEqual(Enum::"PTV Planning Source Type"::"Demand Forecast", ReqLine."PTV Parent Source Type", 'Parent type was not the forecast.');
        Assert.AreEqual(ForecastTok, ReqLine."PTV Parent Source No.", 'Parent number was not the forecast.');
        Assert.IsFalse(ReqLine."PTV Multiple Parents", 'A single forecast parent was marked as multiple.');

        Trace.SetRange("Child Wksh. Template Name", TemplateTok);
        Trace.SetRange("Child Line No.", ReqLine."Line No.");
        Assert.AreEqual(1, Trace.Count(), 'One trace entry was expected.');
        Trace.FindFirst();
        Assert.AreEqual(WorkDate(), Trace."Root Forecast Date", 'Forecast date was not stored.');
    end;

    [Test]
    procedure SemiFinishedLineInheritsFinishedGoodParent()
    var
        FgLine: Record "Requisition Line";
        SfgLine: Record "Requisition Line";
    begin
        Initialize();
        FgLine := CreateForecastLine(10000, FgItemTok, 10);
        SfgLine := CreateComponentLine(FgLine, 20000, SfgItemTok, 4);

        Assert.AreEqual(ForecastTok, SfgLine."PTV Root Demand Forecast", 'Semi-finished line lost the root forecast.');
        Assert.AreEqual(FgItemTok, SfgLine."PTV Root FG Item No.", 'Semi-finished line lost the root item.');
        Assert.AreEqual(Enum::"PTV Planning Source Type"::"Planning Worksheet", SfgLine."PTV Parent Source Type", 'Parent type was not the worksheet.');
        Assert.AreEqual(FgLine."Line No.", SfgLine."PTV Parent Source Line No.", 'Parent line was not the finished-good line.');
        Assert.AreEqual(TemplateTok, SfgLine."PTV Parent Wksh. Template", 'Parent worksheet template was not stored.');
        Assert.AreEqual(BatchTok, SfgLine."PTV Parent Wksh. Batch Name", 'Parent worksheet batch was not stored.');
        Assert.AreEqual(FgItemTok, SfgLine."PTV Parent Source No.", 'Parent number was not the finished-good item.');
    end;

    [Test]
    procedure OneSupplyForTwoParentsShowsMultiple()
    var
        FirstParent: Record "Requisition Line";
        SecondParent: Record "Requisition Line";
        ChildLine: Record "Requisition Line";
        Trace: Record "PTV Planning Trace Entry";
    begin
        Initialize();
        FirstParent := CreateForecastLine(10000, FgItemTok, 5);
        SecondParent := CreateForecastLine(11000, FgItem2Tok, 7);
        ChildLine := CreateLineForTwoParents(FirstParent, SecondParent, 30000, SfgItemTok, 3);

        Assert.IsTrue(ChildLine."PTV Multiple Parents", 'Two parents were not flagged.');
        Assert.AreEqual('Multiple (Drill-down)', ChildLine.PTVParentSourceCaption(), 'Multiple parents were not shown as a drill-down caption.');

        Trace.SetRange("Child Wksh. Template Name", TemplateTok);
        Trace.SetRange("Child Wksh. Batch Name", BatchTok);
        Trace.SetRange("Child Line No.", ChildLine."Line No.");
        Assert.AreEqual(2, Trace.Count(), 'Each parent should have its own trace entry.');
    end;

    [Test]
    procedure CarryOutFinishedGoodRetargetsSemiFinishedLine()
    var
        FgLine: Record "Requisition Line";
        SfgLine: Record "Requisition Line";
        ProdOrder: Record "Production Order";
        ProdOrderLine: Record "Prod. Order Line";
    begin
        Initialize();
        FgLine := CreateForecastLine(10000, FgItemTok, 10);
        SfgLine := CreateComponentLine(FgLine, 20000, SfgItemTok, 4);
        ProdOrder := CreateProdOrder(Enum::"Production Order Status"::Planned, FgOrderTok, FgItemTok);
        ProdOrderLine := CreateProdOrderLine(ProdOrder, 10000, FgItemTok);

        TraceMgt.HandOffProdOrderHeader(ProdOrder, FgLine);
        TraceMgt.HandOffProdOrderLine(ProdOrder, ProdOrderLine, FgLine);

        ProdOrder.Get(ProdOrder.Status, ProdOrder."No.");
        Assert.AreEqual(ForecastTok, ProdOrder."PTV Root Demand Forecast", 'Finished-good order lost the forecast.');
        Assert.AreEqual(FgOrderTok, ProdOrder."PTV Root FG Prod. Order No.", 'Finished-good order did not become the root order.');
        Assert.AreEqual(ForecastTok, ProdOrderLine."PTV Root Demand Forecast", 'Finished-good line lost the forecast.');

        SfgLine.Get(TemplateTok, BatchTok, SfgLine."Line No.");
        Assert.AreEqual(Enum::"PTV Planning Source Type"::"Planned Prod. Order", SfgLine."PTV Parent Source Type", 'Semi-finished parent type was not updated.');
        Assert.AreEqual(FgOrderTok, SfgLine."PTV Parent Source No.", 'Semi-finished parent number was not the new order.');
        Assert.AreEqual(FgOrderTok, SfgLine."PTV Root FG Prod. Order No.", 'Semi-finished line did not receive the root order.');
        Assert.AreEqual(ForecastTok, SfgLine."PTV Root Demand Forecast", 'Semi-finished line lost the original forecast.');
    end;

    [Test]
    procedure CarryOutSemiFinishedKeepsRootFinishedGoodOrder()
    var
        FgLine: Record "Requisition Line";
        SfgLine: Record "Requisition Line";
        FgOrder: Record "Production Order";
        FgOrderLine: Record "Prod. Order Line";
        SfgOrder: Record "Production Order";
        SfgOrderLine: Record "Prod. Order Line";
    begin
        Initialize();
        FgLine := CreateForecastLine(10000, FgItemTok, 10);
        SfgLine := CreateComponentLine(FgLine, 20000, SfgItemTok, 4);
        FgOrder := CreateProdOrder(Enum::"Production Order Status"::Planned, FgOrderTok, FgItemTok);
        FgOrderLine := CreateProdOrderLine(FgOrder, 10000, FgItemTok);
        TraceMgt.HandOffProdOrderHeader(FgOrder, FgLine);
        TraceMgt.HandOffProdOrderLine(FgOrder, FgOrderLine, FgLine);
        SfgLine.Get(TemplateTok, BatchTok, SfgLine."Line No.");

        SfgOrder := CreateProdOrder(Enum::"Production Order Status"::Planned, SfgOrderTok, SfgItemTok);
        SfgOrderLine := CreateProdOrderLine(SfgOrder, 10000, SfgItemTok);
        TraceMgt.HandOffProdOrderHeader(SfgOrder, SfgLine);
        TraceMgt.HandOffProdOrderLine(SfgOrder, SfgOrderLine, SfgLine);

        SfgOrder.Get(SfgOrder.Status, SfgOrder."No.");
        Assert.AreEqual(ForecastTok, SfgOrder."PTV Root Demand Forecast", 'Semi-finished order lost the forecast.');
        Assert.AreEqual(FgOrderTok, SfgOrder."PTV Root FG Prod. Order No.", 'Semi-finished order replaced the root finished-good order.');
        Assert.AreEqual(FgOrderTok, SfgOrder."PTV Parent Source No.", 'Semi-finished order lost its finished-good parent.');
        Assert.AreEqual(Enum::"PTV Planning Source Type"::"Planned Prod. Order", SfgOrder."PTV Parent Source Type", 'Semi-finished parent type was not the finished-good order.');
        Assert.AreEqual(FgOrderTok, SfgOrderLine."PTV Root FG Prod. Order No.", 'Semi-finished order line lost the root order.');
    end;

    [Test]
    procedure StatusChangeUpdatesChildParentType()
    var
        FgLine: Record "Requisition Line";
        SfgLine: Record "Requisition Line";
        PlannedOrder: Record "Production Order";
        PlannedLine: Record "Prod. Order Line";
        FirmOrder: Record "Production Order";
    begin
        Initialize();
        FgLine := CreateForecastLine(10000, FgItemTok, 10);
        SfgLine := CreateComponentLine(FgLine, 20000, SfgItemTok, 4);
        PlannedOrder := CreateProdOrder(Enum::"Production Order Status"::Planned, FgOrderTok, FgItemTok);
        PlannedLine := CreateProdOrderLine(PlannedOrder, 10000, FgItemTok);
        TraceMgt.HandOffProdOrderHeader(PlannedOrder, FgLine);
        TraceMgt.HandOffProdOrderLine(PlannedOrder, PlannedLine, FgLine);

        FirmOrder := CreateProdOrder(Enum::"Production Order Status"::"Firm Planned", FgOrderTok, FgItemTok);
        TraceMgt.HandOffStatus(PlannedOrder, FirmOrder);

        SfgLine.Get(TemplateTok, BatchTok, SfgLine."Line No.");
        Assert.AreEqual(Enum::"PTV Planning Source Type"::"Firm Planned Prod. Order", SfgLine."PTV Parent Source Type", 'Status change did not update the child parent type.');
        Assert.AreEqual(FgOrderTok, SfgLine."PTV Parent Source No.", 'Status change changed the parent order number.');
        Assert.AreEqual(ForecastTok, FirmOrder."PTV Root Demand Forecast", 'The firm planned order lost the forecast.');
    end;

    [Test]
    procedure ChildCarriedOutBeforeSourceNoStillJoinsFinishedGood()
    var
        FgLine: Record "Requisition Line";
        SfgLine: Record "Requisition Line";
        FgOrder: Record "Production Order";
        FgOrderLine: Record "Prod. Order Line";
        SfgOrder: Record "Production Order";
        SfgOrderLine: Record "Prod. Order Line";
        Node: Record "PTV Planning Trace Node" temporary;
    begin
        Initialize();
        FgLine := CreateForecastLine(10000, FgItemTok, 10);
        SfgLine := CreateComponentLine(FgLine, 20000, SfgItemTok, 4);

        SfgOrder := CreateProdOrder(Enum::"Production Order Status"::"Firm Planned", SfgOrderTok, SfgItemTok);
        SfgOrderLine := CreateProdOrderLine(SfgOrder, 10000, SfgItemTok);
        ClearSourceNo(SfgOrder);
        TraceMgt.HandOffProdOrderHeader(SfgOrder, SfgLine);
        TraceMgt.HandOffProdOrderLine(SfgOrder, SfgOrderLine, SfgLine);

        FgOrder := CreateProdOrder(Enum::"Production Order Status"::"Firm Planned", FgOrderTok, FgItemTok);
        FgOrderLine := CreateProdOrderLine(FgOrder, 10000, FgItemTok);
        ClearSourceNo(FgOrder);
        TraceMgt.HandOffProdOrderHeader(FgOrder, FgLine);
        TraceMgt.HandOffProdOrderLine(FgOrder, FgOrderLine, FgLine);

        SfgOrder.Get(SfgOrder.Status, SfgOrder."No.");
        Assert.AreEqual(FgOrderTok, SfgOrder."PTV Root FG Prod. Order No.", 'Semi-finished order did not inherit the finished-good order.');
        Assert.AreEqual(FgOrderTok, SfgOrder."PTV Parent Source No.", 'Semi-finished order did not keep the finished-good parent.');
        Assert.AreEqual(FgItemTok, SfgOrder."PTV Root FG Item No.", 'Semi-finished order lost the finished-good item.');

        TraceMgt.BuildTree(Node, '', FgItemTok, SfgOrder."PTV Root FG Prod. Order No.");
        AssertTreeNode(Node, FgOrderTok, 0);
        AssertTreeNode(Node, SfgOrderTok, 1);
    end;

    [Test]
    procedure ChildOrderWithoutStoredRootStillShowsParentChain()
    var
        FgLine: Record "Requisition Line";
        SfgLine: Record "Requisition Line";
        FgOrder: Record "Production Order";
        FgOrderLine: Record "Prod. Order Line";
        SfgOrder: Record "Production Order";
        SfgOrderLine: Record "Prod. Order Line";
        Trace: Record "PTV Planning Trace Entry";
        Node: Record "PTV Planning Trace Node" temporary;
        RootOrderNo: Code[20];
    begin
        Initialize();
        FgLine := CreateForecastLine(10000, FgItemTok, 10);
        SfgLine := CreateComponentLine(FgLine, 20000, SfgItemTok, 4);
        FgOrder := CreateProdOrder(Enum::"Production Order Status"::"Firm Planned", FgOrderTok, FgItemTok);
        FgOrderLine := CreateProdOrderLine(FgOrder, 10000, FgItemTok);
        TraceMgt.HandOffProdOrderHeader(FgOrder, FgLine);
        TraceMgt.HandOffProdOrderLine(FgOrder, FgOrderLine, FgLine);
        SfgLine.Get(TemplateTok, BatchTok, SfgLine."Line No.");

        SfgOrder := CreateProdOrder(Enum::"Production Order Status"::"Firm Planned", SfgOrderTok, SfgItemTok);
        SfgOrderLine := CreateProdOrderLine(SfgOrder, 10000, SfgItemTok);
        TraceMgt.HandOffProdOrderHeader(SfgOrder, SfgLine);
        TraceMgt.HandOffProdOrderLine(SfgOrder, SfgOrderLine, SfgLine);

        SfgOrder.Get(SfgOrder.Status, SfgOrder."No.");
        SfgOrder."PTV Root FG Prod. Order No." := '';
        SfgOrder.Modify(false);
        Trace.SetRange("Child Document No.", SfgOrder."No.");
        Trace.SetRange("Child Document Type", Trace."Child Document Type"::"Firm Planned Prod. Order");
        if Trace.FindSet(true) then
            repeat
                Trace."Root FG Order No." := '';
                Trace.Modify(false);
            until Trace.Next() = 0;

        RootOrderNo := TraceMgt.ResolveRootOrderForProdOrder(SfgOrder);
        Assert.AreEqual(FgOrderTok, RootOrderNo, 'Opening the child order did not find the finished-good order.');
        TraceMgt.BuildTree(Node, '', SfgOrder."PTV Root FG Item No.", RootOrderNo);
        AssertTreeNode(Node, FgOrderTok, 0);
        AssertTreeNode(Node, SfgOrderTok, 1);
    end;

    [Test]
    procedure LowerLevelComponentStaysUnderItsProdOrder()
    var
        FgLine: Record "Requisition Line";
        SfgLine: Record "Requisition Line";
        CompLine: Record "Requisition Line";
        FgOrder: Record "Production Order";
        FgOrderLine: Record "Prod. Order Line";
        SfgOrder: Record "Production Order";
        SfgOrderLine: Record "Prod. Order Line";
        Node: Record "PTV Planning Trace Node" temporary;
    begin
        Initialize();
        FgLine := CreateForecastLine(10000, FgItemTok, 10);
        SfgLine := CreateComponentLine(FgLine, 20000, SfgItemTok, 4);
        CompLine := CreateComponentLine(SfgLine, 30000, CompItemTok, 2);
        FgOrder := CreateProdOrder(Enum::"Production Order Status"::Planned, FgOrderTok, FgItemTok);
        FgOrderLine := CreateProdOrderLine(FgOrder, 10000, FgItemTok);
        TraceMgt.HandOffProdOrderHeader(FgOrder, FgLine);
        TraceMgt.HandOffProdOrderLine(FgOrder, FgOrderLine, FgLine);
        SfgLine.Get(TemplateTok, BatchTok, SfgLine."Line No.");

        SfgOrder := CreateProdOrder(Enum::"Production Order Status"::Planned, SfgOrderTok, SfgItemTok);
        SfgOrderLine := CreateProdOrderLine(SfgOrder, 10000, SfgItemTok);
        TraceMgt.HandOffProdOrderHeader(SfgOrder, SfgLine);
        TraceMgt.HandOffProdOrderLine(SfgOrder, SfgOrderLine, SfgLine);

        CompLine.Get(TemplateTok, BatchTok, CompLine."Line No.");
        Assert.AreEqual(SfgOrderTok, CompLine."PTV Parent Source No.", 'Component parent was not the semi-finished order.');
        Assert.AreEqual(0, CompLine."PTV Parent Source Line No.", 'Carry-out should clear the parent line on the component.');

        TraceMgt.BuildTree(Node, ForecastTok, FgItemTok, FgOrderTok);
        AssertTreeNode(Node, SfgOrderTok, 2);
        AssertTreeNode(Node, CompItemTok, 3);
    end;

    local procedure Initialize()
    var
        Trace: Record "PTV Planning Trace Entry";
        ReqLine: Record "Requisition Line";
        ProdOrder: Record "Production Order";
        ProdOrderLine: Record "Prod. Order Line";
    begin
        TraceMgt.ClearPlanCache();
        Trace.SetFilter("Item No.", 'PTV-*');
        Trace.DeleteAll(false);
        ReqLine.SetRange("Worksheet Template Name", TemplateTok);
        ReqLine.SetRange("Journal Batch Name", BatchTok);
        ReqLine.DeleteAll(false);
        ProdOrderLine.SetFilter("Prod. Order No.", 'PTV-*');
        ProdOrderLine.DeleteAll(false);
        ProdOrder.SetFilter("No.", 'PTV-*');
        ProdOrder.DeleteAll(false);
    end;

    local procedure CreateForecastLine(LineNo: Integer; ItemNo: Code[20]; Qty: Decimal): Record "Requisition Line"
    var
        ReqLine: Record "Requisition Line";
        SupplyProfile: Record "Inventory Profile";
        DemandProfile: Record "Inventory Profile";
    begin
        TraceMgt.CacheForecastDemand(LineNo, ForecastTok, WorkDate(), ItemNo);
        DemandProfile := DemandProfileForForecast(LineNo, ItemNo, Qty);
        SupplyProfile := SupplyProfileFor(LineNo + 1, ItemNo, Qty, 0);
        TraceMgt.RecordPeg(SupplyProfile, DemandProfile, Qty);
        ReqLine := BlankReqLine(LineNo, ItemNo, Qty, 0);
        TraceMgt.StampRequisitionLine(ReqLine, SupplyProfile, DemandProfile, ForecastTok);
        ReqLine.Insert(false);
        TraceMgt.WriteTraceEntries(ReqLine);
        exit(ReqLine);
    end;

    local procedure CreateComponentLine(ParentLine: Record "Requisition Line"; LineNo: Integer; ItemNo: Code[20]; Qty: Decimal): Record "Requisition Line"
    var
        ReqLine: Record "Requisition Line";
        PlanningComponent: Record "Planning Component";
        SupplyProfile: Record "Inventory Profile";
        DemandProfile: Record "Inventory Profile";
    begin
        PlanningComponent.Init();
        PlanningComponent."Worksheet Template Name" := ParentLine."Worksheet Template Name";
        PlanningComponent."Worksheet Batch Name" := ParentLine."Journal Batch Name";
        PlanningComponent."Worksheet Line No." := ParentLine."Line No.";
        PlanningComponent."Line No." := LineNo;
        PlanningComponent."Item No." := ItemNo;
        TraceMgt.CacheComponentDemand(LineNo, PlanningComponent);

        DemandProfile.Init();
        DemandProfile."Line No." := LineNo;
        DemandProfile."Item No." := ItemNo;
        DemandProfile.IsSupply := false;
        DemandProfile."Source Type" := Database::"Planning Component";
        DemandProfile."Source ID" := ParentLine."Worksheet Template Name";
        DemandProfile."Source Batch Name" := ParentLine."Journal Batch Name";
        DemandProfile."Source Ref. No." := PlanningComponent."Line No.";
        DemandProfile."Remaining Quantity (Base)" := Qty;
        DemandProfile."Planning Level Code" := ParentLine."Planning Level";

        SupplyProfile := SupplyProfileFor(LineNo + 1, ItemNo, Qty, ParentLine."Planning Level" + 1);
        TraceMgt.RecordPeg(SupplyProfile, DemandProfile, Qty);
        ReqLine := BlankReqLine(LineNo, ItemNo, Qty, ParentLine."Planning Level" + 1);
        TraceMgt.StampRequisitionLine(ReqLine, SupplyProfile, DemandProfile, '');
        ReqLine.Insert(false);
        TraceMgt.WriteTraceEntries(ReqLine);
        exit(ReqLine);
    end;

    local procedure CreateLineForTwoParents(FirstParent: Record "Requisition Line"; SecondParent: Record "Requisition Line"; LineNo: Integer; ItemNo: Code[20]; Qty: Decimal): Record "Requisition Line"
    var
        ReqLine: Record "Requisition Line";
        SupplyProfile: Record "Inventory Profile";
    begin
        CacheParentComponent(FirstParent, LineNo, ItemNo);
        CacheParentComponent(SecondParent, LineNo + 50, ItemNo);
        SupplyProfile := SupplyProfileFor(LineNo + 1, ItemNo, Qty, FirstParent."Planning Level" + 1);
        TraceMgt.RecordPeg(SupplyProfile, ComponentDemand(FirstParent, LineNo, ItemNo, Qty), Qty);
        TraceMgt.RecordPeg(SupplyProfile, ComponentDemand(SecondParent, LineNo + 50, ItemNo, Qty), Qty);
        ReqLine := BlankReqLine(LineNo, ItemNo, Qty, FirstParent."Planning Level" + 1);
        TraceMgt.StampRequisitionLine(ReqLine, SupplyProfile, ComponentDemand(FirstParent, LineNo, ItemNo, Qty), '');
        ReqLine.Insert(false);
        TraceMgt.WriteTraceEntries(ReqLine);
        exit(ReqLine);
    end;

    local procedure CacheParentComponent(ParentLine: Record "Requisition Line"; ProfileLineNo: Integer; ItemNo: Code[20])
    var
        PlanningComponent: Record "Planning Component";
    begin
        PlanningComponent.Init();
        PlanningComponent."Worksheet Template Name" := ParentLine."Worksheet Template Name";
        PlanningComponent."Worksheet Batch Name" := ParentLine."Journal Batch Name";
        PlanningComponent."Worksheet Line No." := ParentLine."Line No.";
        PlanningComponent."Line No." := ProfileLineNo;
        PlanningComponent."Item No." := ItemNo;
        TraceMgt.CacheComponentDemand(ProfileLineNo, PlanningComponent);
    end;

    local procedure ComponentDemand(ParentLine: Record "Requisition Line"; ProfileLineNo: Integer; ItemNo: Code[20]; Qty: Decimal): Record "Inventory Profile"
    var
        DemandProfile: Record "Inventory Profile";
    begin
        DemandProfile.Init();
        DemandProfile."Line No." := ProfileLineNo;
        DemandProfile."Item No." := ItemNo;
        DemandProfile.IsSupply := false;
        DemandProfile."Source Type" := Database::"Planning Component";
        DemandProfile."Source ID" := ParentLine."Worksheet Template Name";
        DemandProfile."Source Batch Name" := ParentLine."Journal Batch Name";
        DemandProfile."Source Ref. No." := ProfileLineNo;
        DemandProfile."Remaining Quantity (Base)" := Qty;
        DemandProfile."Planning Level Code" := ParentLine."Planning Level";
        exit(DemandProfile);
    end;

    local procedure BlankReqLine(LineNo: Integer; ItemNo: Code[20]; Qty: Decimal; PlanningLevel: Integer): Record "Requisition Line"
    var
        ReqLine: Record "Requisition Line";
    begin
        ReqLine.Init();
        ReqLine."Worksheet Template Name" := TemplateTok;
        ReqLine."Journal Batch Name" := BatchTok;
        ReqLine."Line No." := LineNo;
        ReqLine.Type := ReqLine.Type::Item;
        ReqLine."No." := ItemNo;
        ReqLine.Quantity := Qty;
        ReqLine."Quantity (Base)" := Qty;
        ReqLine."Replenishment System" := ReqLine."Replenishment System"::"Prod. Order";
        ReqLine."Action Message" := ReqLine."Action Message"::New;
        ReqLine."Planning Level" := PlanningLevel;
        exit(ReqLine);
    end;

    local procedure SupplyProfileFor(LineNo: Integer; ItemNo: Code[20]; Qty: Decimal; PlanningLevel: Integer): Record "Inventory Profile"
    var
        SupplyProfile: Record "Inventory Profile";
    begin
        SupplyProfile.Init();
        SupplyProfile."Line No." := LineNo;
        SupplyProfile."Item No." := ItemNo;
        SupplyProfile.IsSupply := true;
        SupplyProfile."Remaining Quantity (Base)" := Qty;
        SupplyProfile."Quantity (Base)" := Qty;
        SupplyProfile."Planning Level Code" := PlanningLevel;
        exit(SupplyProfile);
    end;

    local procedure DemandProfileForForecast(LineNo: Integer; ItemNo: Code[20]; Qty: Decimal): Record "Inventory Profile"
    var
        DemandProfile: Record "Inventory Profile";
    begin
        DemandProfile.Init();
        DemandProfile."Line No." := LineNo;
        DemandProfile."Item No." := ItemNo;
        DemandProfile.IsSupply := false;
        DemandProfile."Source Type" := Database::"Production Forecast Entry";
        DemandProfile."Source ID" := ForecastTok;
        DemandProfile."Due Date" := WorkDate();
        DemandProfile."Remaining Quantity (Base)" := Qty;
        exit(DemandProfile);
    end;

    local procedure AssertTreeNode(var Node: Record "PTV Planning Trace Node" temporary; DocumentNo: Code[20]; ExpectedIndent: Integer)
    begin
        Node.Reset();
        Node.SetRange("Document No.", DocumentNo);
        Assert.IsTrue(Node.FindFirst(), StrSubstNo('Tree is missing document %1.', DocumentNo));
        Assert.AreEqual(1, Node.Count(), StrSubstNo('Tree repeated document %1.', DocumentNo));
        Assert.AreEqual(ExpectedIndent, Node.Indentation, StrSubstNo('Tree indented document %1 at the wrong level.', DocumentNo));
    end;

    local procedure ClearSourceNo(var ProdOrder: Record "Production Order")
    begin
        ProdOrder."Source No." := '';
        ProdOrder.Modify(false);
    end;

    local procedure CreateProdOrder(Status: Enum "Production Order Status"; OrderNo: Code[20]; ItemNo: Code[20]): Record "Production Order"
    var
        ProdOrder: Record "Production Order";
    begin
        ProdOrder.Init();
        ProdOrder.Status := Status;
        ProdOrder."No." := OrderNo;
        ProdOrder."Source Type" := ProdOrder."Source Type"::Item;
        ProdOrder."Source No." := ItemNo;
        ProdOrder.Insert(false);
        exit(ProdOrder);
    end;

    local procedure CreateProdOrderLine(ProdOrder: Record "Production Order"; LineNo: Integer; ItemNo: Code[20]): Record "Prod. Order Line"
    var
        ProdOrderLine: Record "Prod. Order Line";
    begin
        ProdOrderLine.Init();
        ProdOrderLine.Status := ProdOrder.Status;
        ProdOrderLine."Prod. Order No." := ProdOrder."No.";
        ProdOrderLine."Line No." := LineNo;
        ProdOrderLine."Item No." := ItemNo;
        ProdOrderLine.Insert(false);
        exit(ProdOrderLine);
    end;
}
#endif
