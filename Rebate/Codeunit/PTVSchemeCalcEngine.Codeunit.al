codeunit 77201 "PTV Scheme Calc Engine"
{
    TableNo = "PTV Scheme Header";

    trigger OnRun()
    begin
        CalculateScheme(Rec);
    end;

    var
        GrowthPayGate: Codeunit "PTV Scheme Growth & Pay Gate";

    /// <summary>
    /// Calculates scheme entitlements across all evaluation periods and eligible customers.
    /// </summary>
    /// <param name="SchemeHdr">Released scheme header.</param>
    /// <returns>Number of entitlements generated.</returns>
    procedure CalculateScheme(var SchemeHdr: Record "PTV Scheme Header"): Integer
    var
        TempPeriod: Record "Date" temporary;
        Customer: Record Customer;
        ProcessedCust: List of [Code[20]];
        CustNo: Code[20];
        CreatedCount: Integer;
        NotReleasedErr: Label 'Scheme %1 must have Status = Released before calculation.';
    begin
        SchemeHdr.TestField("Start Date");
        SchemeHdr.TestField("End Date");
        if SchemeHdr.Status <> SchemeHdr.Status::Released then
            Error(NotReleasedErr, SchemeHdr.Code);

        ClearOpenEntitlements(SchemeHdr.Code);
        BuildEvaluationPeriods(SchemeHdr, TempPeriod);
        CollectEligibleCustomers(SchemeHdr, ProcessedCust);

        foreach CustNo in ProcessedCust do
            if Customer.Get(CustNo) then
                if TempPeriod.FindSet() then
                    repeat
                        CreatedCount += ProcessCustomerPeriod(SchemeHdr, Customer, TempPeriod."Period Start", TempPeriod."Period End");
                    until TempPeriod.Next() = 0;

        exit(CreatedCount);
    end;

    local procedure ProcessCustomerPeriod(SchemeHdr: Record "PTV Scheme Header"; Customer: Record Customer; PeriodStart: Date; PeriodEnd: Date): Integer
    begin
        if (SchemeHdr."Special Price Handling" = SchemeHdr."Special Price Handling"::"Exclude Customer") and
           GrowthPayGate.HasSpecialPriceOrTieUpInPeriod(Customer."No.", PeriodStart, PeriodEnd)
        then
            exit(0);

        if SchemeHdr."Scheme Type" = SchemeHdr."Scheme Type"::"Value Rebate" then begin
            if CalculateWholePeriodValueRebate(SchemeHdr, Customer, PeriodStart, PeriodEnd) then
                exit(1);
            exit(0);
        end;

        exit(CalculateLineBasedEntitlements(SchemeHdr, Customer, PeriodStart, PeriodEnd));
    end;

    local procedure ClearOpenEntitlements(SchemeCode: Code[20])
    var
        Entitlement: Record "PTV Scheme Entitlement";
        AppliedEntry: Record "PTV Scheme Applied Entry";
    begin
        Entitlement.SetRange("Scheme Code", SchemeCode);
        Entitlement.SetFilter(Status, '%1|%2', Entitlement.Status::Open, Entitlement.Status::Rejected);
        if Entitlement.FindSet() then
            repeat
                AppliedEntry.SetRange("Entitlement Entry No.", Entitlement."Entry No.");
                AppliedEntry.DeleteAll();
            until Entitlement.Next() = 0;
        Entitlement.DeleteAll();
    end;

    local procedure BuildEvaluationPeriods(SchemeHdr: Record "PTV Scheme Header"; var TempPeriod: Record Date temporary)
    var
        CurrStart: Date;
        CurrEnd: Date;
    begin
        TempPeriod.Reset();
        TempPeriod.DeleteAll();

        if SchemeHdr."Evaluation Period" = SchemeHdr."Evaluation Period"::"Full Period" then begin
            AddPeriod(TempPeriod, SchemeHdr."Start Date", SchemeHdr."End Date");
            exit;
        end;

        CurrStart := SchemeHdr."Start Date";
        while CurrStart <= SchemeHdr."End Date" do begin
            case SchemeHdr."Evaluation Period" of
                SchemeHdr."Evaluation Period"::Monthly:
                    CurrEnd := CalcDate('<CM>', CurrStart);
                SchemeHdr."Evaluation Period"::Quarterly:
                    CurrEnd := CalcDate('<CQ>', CurrStart);
                SchemeHdr."Evaluation Period"::Annually:
                    CurrEnd := CalcDate('<CY>', CurrStart);
            end;
            if CurrEnd > SchemeHdr."End Date" then
                CurrEnd := SchemeHdr."End Date";
            AddPeriod(TempPeriod, CurrStart, CurrEnd);
            CurrStart := CurrEnd + 1;
        end;
    end;

    local procedure AddPeriod(var TempPeriod: Record Date temporary; PeriodStart: Date; PeriodEnd: Date)
    begin
        TempPeriod.Init();
        TempPeriod."Period Type" := TempPeriod."Period Type"::Date;
        TempPeriod."Period Start" := PeriodStart;
        TempPeriod."Period End" := PeriodEnd;
        TempPeriod.Insert();
    end;

    local procedure CollectEligibleCustomers(SchemeHdr: Record "PTV Scheme Header"; var CustList: List of [Code[20]])
    var
        SalesInvHdr: Record "Sales Invoice Header";
        Customer: Record Customer;
    begin
        SalesInvHdr.SetCurrentKey("Posting Date");
        SalesInvHdr.SetRange("Posting Date", SchemeHdr."Start Date", SchemeHdr."End Date");
        if SchemeHdr."Location Filter" <> '' then
            SalesInvHdr.SetFilter("Location Code", SchemeHdr."Location Filter");
        if SchemeHdr."Customer Filter" <> '' then
            SalesInvHdr.SetFilter("Sell-to Customer No.", SchemeHdr."Customer Filter");
        SalesInvHdr.SetLoadFields("Sell-to Customer No.");
        if SalesInvHdr.FindSet() then
            repeat
                if not CustList.Contains(SalesInvHdr."Sell-to Customer No.") then
                    if Customer.Get(SalesInvHdr."Sell-to Customer No.") then
                        if GrowthPayGate.IsCustomerEligible(SchemeHdr, Customer) then
                            CustList.Add(SalesInvHdr."Sell-to Customer No.");
            until SalesInvHdr.Next() = 0;
    end;

    local procedure CalculateLineBasedEntitlements(SchemeHdr: Record "PTV Scheme Header"; Customer: Record Customer; PeriodStart: Date; PeriodEnd: Date): Integer
    var
        SchemeLine: Record "PTV Scheme Line";
        CreatedCount: Integer;
    begin
        SchemeLine.SetRange("Scheme Code", SchemeHdr.Code);
        SchemeLine.SetRange("Line Type", SchemeLine."Line Type"::Include);
        if not SchemeLine.FindSet() then
            exit(0);

        repeat
            if ProcessSingleSchemeLine(SchemeHdr, SchemeLine, Customer, PeriodStart, PeriodEnd) then
                CreatedCount += 1;
        until SchemeLine.Next() = 0;

        exit(CreatedCount);
    end;

    local procedure ProcessSingleSchemeLine(SchemeHdr: Record "PTV Scheme Header"; SchemeLine: Record "PTV Scheme Line"; Customer: Record Customer; PeriodStart: Date; PeriodEnd: Date): Boolean
    var
        Slab: Record "PTV Scheme Slab";
        Entitlement: Record "PTV Scheme Entitlement";
        AppliedEntry: Record "PTV Scheme Applied Entry";
        TempApplied: Record "PTV Scheme Applied Entry" temporary;
        Qty: Decimal;
        Litres: Decimal;
        Kg: Decimal;
        EligibleQty: Decimal;
        GrossVal: Decimal;
        NetVal: Decimal;
        PriorQty: Decimal;
        PriorVal: Decimal;
        GrowthPct: Decimal;
        MinGrowthPct: Decimal;
        GrowthOK: Boolean;
        PayCleared: Boolean;
        UnpaidAmt: Decimal;
        RebateAmt: Decimal;
        FOCQty: Decimal;
        PriorStart: Date;
        PriorEnd: Date;
        LuxVal: Decimal;
        PremVal: Decimal;
        BudgVal: Decimal;
    begin
        if HasEntitlementForPeriod(SchemeHdr.Code, Customer."No.", PeriodStart, PeriodEnd, SchemeLine."Line No.") then
            exit(false);

        PriorStart := CalcDate('<-1Y>', PeriodStart);
        PriorEnd := CalcDate('<-1Y>', PeriodEnd);

        AggregateSalesForPeriod(
            SchemeHdr, SchemeLine, true, Customer."No.", PeriodStart, PeriodEnd,
            Qty, Litres, Kg, EligibleQty, GrossVal, NetVal, LuxVal, PremVal, BudgVal, true, TempApplied);

        if (EligibleQty <= 0) and (NetVal <= 0) then
            exit(false);
        if (SchemeLine."Minimum Quantity" > 0) and (EligibleQty < SchemeLine."Minimum Quantity") then
            exit(false);
        if (SchemeLine."Minimum Value" > 0) and (NetVal < SchemeLine."Minimum Value") then
            exit(false);

        AggregateSalesForPeriod(
            SchemeHdr, SchemeLine, true, Customer."No.", PriorStart, PriorEnd,
            Qty, Litres, Kg, PriorQty, GrossVal, PriorVal, LuxVal, PremVal, BudgVal, false, TempApplied);

        GrowthPct := GrowthPayGate.ComputeGrowthPct(EligibleQty, PriorQty);
        MinGrowthPct := SchemeLine."Min Growth %";
        if MinGrowthPct = 0 then
            MinGrowthPct := SchemeHdr."Default Min Growth %";

        if not FindBestSlab(SchemeHdr, SchemeLine."Line No.", EligibleQty, NetVal, GrowthPct, MinGrowthPct, Slab, GrowthOK) then
            exit(false);

        ComputeLinePayout(Slab, EligibleQty, NetVal, RebateAmt, FOCQty);
        if (RebateAmt = 0) and (FOCQty = 0) and (Slab."Trip Description" = '') then
            exit(false);

        Entitlement.Init();
        Entitlement."Scheme Code" := SchemeHdr.Code;
        Entitlement."Scheme Line No." := SchemeLine."Line No.";
        Entitlement."Slab No." := Slab."Slab No.";
        Entitlement."Customer No." := Customer."No.";
        Entitlement."Scheme Product Group" := SchemeLine."Scheme Product Group";
        Entitlement."Period Start Date" := PeriodStart;
        Entitlement."Period End Date" := PeriodEnd;
        Entitlement."Calculation Date" := WorkDate();
        Entitlement."Sales Quantity" := Qty;
        Entitlement."Sales Volume Litres" := Litres;
        Entitlement."Sales Weight Kg" := Kg;
        Entitlement."Eligible Qty (Kg/Ltr)" := EligibleQty;
        Entitlement."Gross Sales Value" := GrossVal;
        Entitlement."Net Sales Value" := NetVal;
        Entitlement."Prior Year Qty" := PriorQty;
        Entitlement."Prior Year Value" := PriorVal;
        Entitlement."Growth %" := GrowthPct;
        Entitlement."Growth Qualified" := GrowthOK;
        Entitlement."Discount Type" := Slab."Discount Type";
        if Slab."Discount Type" = Slab."Discount Type"::"FOC Quantity" then
            Entitlement."Reward Choice" := Entitlement."Reward Choice"::"FOC Order"
        else
            Entitlement."Reward Choice" := Entitlement."Reward Choice"::"Credit Note";
        Entitlement."Rebate %" := Slab."Discount %";
        Entitlement."Rate per Unit" := Slab."Rate per Unit";
        Entitlement."Rebate Amount" := RebateAmt;
        Entitlement."Total Rebate Amount" := RebateAmt;
        Entitlement."FOC Item No." := Slab."FOC Item No.";
        Entitlement."FOC Unit of Measure" := Slab."FOC Unit of Measure";
        Entitlement."FOC Quantity" := FOCQty;
        Entitlement."Trip Description" := Slab."Trip Description";
        Entitlement."Qualification Tier Code" := Slab."Qualification Tier Code";
        Entitlement.Status := Entitlement.Status::Open;
        if not GrowthOK then
            Entitlement."Rejection Reason" := StrSubstNo('Growth %1% below minimum %2%.', GrowthPct, MinGrowthPct);
        Entitlement.Insert(true);

        if TempApplied.FindSet() then
            repeat
                AppliedEntry := TempApplied;
                AppliedEntry."Entry No." := 0;
                AppliedEntry."Entitlement Entry No." := Entitlement."Entry No.";
                AppliedEntry.Insert(true);
            until TempApplied.Next() = 0;

        PayCleared := GrowthPayGate.CheckPaymentCleared(SchemeHdr, Customer."No.", PeriodStart, PeriodEnd, Entitlement."Entry No.", UnpaidAmt);
        Entitlement."Payment Cleared" := PayCleared;
        Entitlement."Unpaid Invoice Amount" := UnpaidAmt;
        Entitlement.Modify();

        exit(true);
    end;

    local procedure CalculateWholePeriodValueRebate(SchemeHdr: Record "PTV Scheme Header"; Customer: Record Customer; PeriodStart: Date; PeriodEnd: Date): Boolean
    var
        DummyLine: Record "PTV Scheme Line";
        Slab: Record "PTV Scheme Slab";
        Entitlement: Record "PTV Scheme Entitlement";
        AppliedEntry: Record "PTV Scheme Applied Entry";
        TempApplied: Record "PTV Scheme Applied Entry" temporary;
        Qty: Decimal;
        Litres: Decimal;
        Kg: Decimal;
        EligibleQty: Decimal;
        GrossVal: Decimal;
        NetVal: Decimal;
        PriorQty: Decimal;
        PriorVal: Decimal;
        GrowthPct: Decimal;
        GrowthOK: Boolean;
        PayCleared: Boolean;
        UnpaidAmt: Decimal;
        BaseRebate: Decimal;
        IncrBonus: Decimal;
        LuxVal: Decimal;
        PremVal: Decimal;
        BudgVal: Decimal;
        PriorStart: Date;
        PriorEnd: Date;
    begin
        if HasEntitlementForPeriod(SchemeHdr.Code, Customer."No.", PeriodStart, PeriodEnd, 0) then
            exit(false);

        PriorStart := CalcDate('<-1Y>', PeriodStart);
        PriorEnd := CalcDate('<-1Y>', PeriodEnd);

        AggregateSalesForPeriod(
            SchemeHdr, DummyLine, false, Customer."No.", PeriodStart, PeriodEnd,
            Qty, Litres, Kg, EligibleQty, GrossVal, NetVal, LuxVal, PremVal, BudgVal, true, TempApplied);

        if NetVal <= 0 then
            exit(false);
        if (SchemeHdr."Minimum Net Value" > 0) and (NetVal < SchemeHdr."Minimum Net Value") then
            exit(false);

        AggregateSalesForPeriod(
            SchemeHdr, DummyLine, false, Customer."No.", PriorStart, PriorEnd,
            Qty, Litres, Kg, PriorQty, GrossVal, PriorVal, LuxVal, PremVal, BudgVal, false, TempApplied);

        GrowthPct := GrowthPayGate.ComputeGrowthPct(NetVal, PriorVal);

        if not FindBestSlab(SchemeHdr, 0, EligibleQty, NetVal, GrowthPct, SchemeHdr."Default Min Growth %", Slab, GrowthOK) then
            exit(false);

        ComputeValueRebatePayout(Slab, NetVal, BaseRebate, IncrBonus);

        Entitlement.Init();
        Entitlement."Scheme Code" := SchemeHdr.Code;
        Entitlement."Scheme Line No." := 0;
        Entitlement."Slab No." := Slab."Slab No.";
        Entitlement."Customer No." := Customer."No.";
        Entitlement."Period Start Date" := PeriodStart;
        Entitlement."Period End Date" := PeriodEnd;
        Entitlement."Calculation Date" := WorkDate();
        Entitlement."Sales Quantity" := Qty;
        Entitlement."Sales Volume Litres" := Litres;
        Entitlement."Sales Weight Kg" := Kg;
        Entitlement."Eligible Qty (Kg/Ltr)" := EligibleQty;
        Entitlement."Gross Sales Value" := GrossVal;
        Entitlement."Net Sales Value" := NetVal;
        Entitlement."Prior Year Qty" := PriorQty;
        Entitlement."Prior Year Value" := PriorVal;
        Entitlement."Growth %" := GrowthPct;
        Entitlement."Growth Qualified" := GrowthOK;
        Entitlement."Discount Type" := Slab."Discount Type";
        Entitlement."Reward Choice" := Entitlement."Reward Choice"::"Credit Note";
        Entitlement."Rebate %" := Slab."Discount %";
        Entitlement."Rebate Amount" := BaseRebate;
        Entitlement."Incremental Bonus Amount" := IncrBonus;
        Entitlement."Total Rebate Amount" := BaseRebate + IncrBonus;
        Entitlement."Trip Description" := Slab."Trip Description";
        Entitlement."Qualification Tier Code" := Slab."Qualification Tier Code";
        if NetVal > 0 then begin
            Entitlement."Luxury Mix %" := Round((LuxVal / NetVal) * 100, 0.01);
            Entitlement."Premium Mix %" := Round((PremVal / NetVal) * 100, 0.01);
            Entitlement."Budget Mix %" := Round((BudgVal / NetVal) * 100, 0.01);
        end;
        Entitlement.Status := Entitlement.Status::Open;
        if not GrowthOK then
            Entitlement."Rejection Reason" := StrSubstNo('Growth %1% below slab minimum %2%.', GrowthPct, Slab."Min Growth %");
        Entitlement.Insert(true);

        if TempApplied.FindSet() then
            repeat
                AppliedEntry := TempApplied;
                AppliedEntry."Entry No." := 0;
                AppliedEntry."Entitlement Entry No." := Entitlement."Entry No.";
                AppliedEntry.Insert(true);
            until TempApplied.Next() = 0;

        PayCleared := GrowthPayGate.CheckPaymentCleared(SchemeHdr, Customer."No.", PeriodStart, PeriodEnd, Entitlement."Entry No.", UnpaidAmt);
        Entitlement."Payment Cleared" := PayCleared;
        Entitlement."Unpaid Invoice Amount" := UnpaidAmt;
        Entitlement.Modify();

        exit(true);
    end;

    local procedure AggregateSalesForPeriod(
        SchemeHdr: Record "PTV Scheme Header";
        SchemeLine: Record "PTV Scheme Line";
        UseSpecificLine: Boolean;
        CustomerNo: Code[20];
        PeriodStart: Date;
        PeriodEnd: Date;
        var TotalQty: Decimal;
        var TotalLitres: Decimal;
        var TotalKg: Decimal;
        var TotalEligibleQty: Decimal;
        var TotalGrossVal: Decimal;
        var TotalNetVal: Decimal;
        var LuxVal: Decimal;
        var PremVal: Decimal;
        var BudgVal: Decimal;
        RecordLines: Boolean;
        var TempApplied: Record "PTV Scheme Applied Entry" temporary)
    var
        SalesInvLine: Record "Sales Invoice Line";
        SalesCrLine: Record "Sales Cr.Memo Line";
        EffectiveMeasure: Enum "PTV Rebate Measure";
        GroupCode: Code[20];
        NextTempNo: Integer;
    begin
        TotalQty := 0;
        TotalLitres := 0;
        TotalKg := 0;
        TotalEligibleQty := 0;
        TotalGrossVal := 0;
        TotalNetVal := 0;
        LuxVal := 0;
        PremVal := 0;
        BudgVal := 0;

        if UseSpecificLine then begin
            EffectiveMeasure := SchemeLine."Rebate Measure";
            GroupCode := SchemeLine."Scheme Product Group";
        end else
            EffectiveMeasure := EffectiveMeasure::Auto;

        SalesInvLine.SetCurrentKey("Sell-to Customer No.", "Posting Date", Type);
        SalesInvLine.SetRange("Sell-to Customer No.", CustomerNo);
        SalesInvLine.SetRange("Posting Date", PeriodStart, PeriodEnd);
        SalesInvLine.SetRange(Type, SalesInvLine.Type::Item);
        SalesInvLine.SetLoadFields(
            "Document No.", "Line No.", "No.", "Posting Date", Quantity, "Quantity (Base)",
            "Unit of Measure Code", Amount, "Amount Including VAT", "Location Code",
            "PTV Product Code", "PTV Shade Code", "PTV Pack Code", "PTV FOC Item", "PTV Special Price", "PTV Tie-Up Discount");
        if SalesInvLine.FindSet() then
            repeat
                AccumulateInvLine(
                    SchemeHdr, SchemeLine, UseSpecificLine, CustomerNo, EffectiveMeasure, GroupCode, SalesInvLine,
                    TotalQty, TotalLitres, TotalKg, TotalEligibleQty, TotalGrossVal, TotalNetVal, LuxVal, PremVal, BudgVal,
                    RecordLines, NextTempNo, TempApplied);
            until SalesInvLine.Next() = 0;

        SalesCrLine.SetCurrentKey("Sell-to Customer No.", "Posting Date", Type);
        SalesCrLine.SetRange("Sell-to Customer No.", CustomerNo);
        SalesCrLine.SetRange("Posting Date", PeriodStart, PeriodEnd);
        SalesCrLine.SetRange(Type, SalesCrLine.Type::Item);
        SalesCrLine.SetLoadFields(
            "Document No.", "Line No.", "No.", "Posting Date", Quantity, "Quantity (Base)",
            "Unit of Measure Code", Amount, "Amount Including VAT", "Location Code",
            "PTV Product Code", "PTV Shade Code", "PTV Pack Code", "PTV FOC Item", "PTV Special Price", "PTV Tie-Up Discount");
        if SalesCrLine.FindSet() then
            repeat
                AccumulateCrLine(
                    SchemeHdr, SchemeLine, UseSpecificLine, CustomerNo, EffectiveMeasure, GroupCode, SalesCrLine,
                    TotalQty, TotalLitres, TotalKg, TotalEligibleQty, TotalGrossVal, TotalNetVal, LuxVal, PremVal, BudgVal,
                    RecordLines, NextTempNo, TempApplied);
            until SalesCrLine.Next() = 0;
    end;

    local procedure AccumulateInvLine(
        SchemeHdr: Record "PTV Scheme Header";
        SchemeLine: Record "PTV Scheme Line";
        UseSpecificLine: Boolean;
        CustomerNo: Code[20];
        EffectiveMeasure: Enum "PTV Rebate Measure";
        GroupCode: Code[20];
        SalesInvLine: Record "Sales Invoice Line";
        var TotalQty: Decimal;
        var TotalLitres: Decimal;
        var TotalKg: Decimal;
        var TotalEligibleQty: Decimal;
        var TotalGrossVal: Decimal;
        var TotalNetVal: Decimal;
        var LuxVal: Decimal;
        var PremVal: Decimal;
        var BudgVal: Decimal;
        RecordLines: Boolean;
        var NextTempNo: Integer;
        var TempApplied: Record "PTV Scheme Applied Entry" temporary)
    var
        Item: Record Item;
        PaintProduct: Record "PTV Paint Product";
        LineLitres: Decimal;
        LineKg: Decimal;
        LineEligibleQty: Decimal;
    begin
        if SchemeHdr."Location Filter" <> '' then
            if not GrowthPayGate.MatchesTextFilter(SalesInvLine."Location Code", SchemeHdr."Location Filter") then
                exit;
        if SchemeHdr."Exclude FOC Lines" and SalesInvLine."PTV FOC Item" then
            exit;
        if (SchemeHdr."Special Price Handling" <> SchemeHdr."Special Price Handling"::Allow) and
           (SalesInvLine."PTV Special Price" or SalesInvLine."PTV Tie-Up Discount")
        then
            exit;
        if SalesInvLine.Amount <= 0 then
            exit;
        if RecordLines and IsDocLineClaimed(SchemeHdr, TempApplied."Source Document Type"::"Sales Invoice", SalesInvLine."Document No.", SalesInvLine."Line No.") then
            exit;

        Item.SetLoadFields("Item Category Code", "PTV Product Code");
        if not Item.Get(SalesInvLine."No.") then
            exit;
        if not IsItemEligibleForScheme(SchemeHdr, SchemeLine, UseSpecificLine, SalesInvLine."No.", SalesInvLine."PTV Product Code", SalesInvLine."PTV Shade Code", SalesInvLine."PTV Pack Code", Item."Item Category Code") then
            exit;

        LineEligibleQty := GrowthPayGate.GetMeasuredQuantity(
            SalesInvLine."No.", SalesInvLine."Unit of Measure Code", SalesInvLine.Quantity, SalesInvLine."Quantity (Base)",
            EffectiveMeasure, GroupCode, LineLitres, LineKg);

        TotalQty += SalesInvLine.Quantity;
        TotalLitres += LineLitres;
        TotalKg += LineKg;
        TotalEligibleQty += LineEligibleQty;
        TotalGrossVal += SalesInvLine."Amount Including VAT";
        TotalNetVal += SalesInvLine.Amount;

        if PaintProduct.Get(SalesInvLine."PTV Product Code") then
            AccumulateSegment(PaintProduct."PTV Product Segment", SalesInvLine.Amount, LuxVal, PremVal, BudgVal);

        if RecordLines then begin
            NextTempNo += 1;
            AddTempApplied(TempApplied, NextTempNo, SchemeHdr, CustomerNo, TempApplied."Source Document Type"::"Sales Invoice",
                SalesInvLine."Document No.", SalesInvLine."Line No.", SalesInvLine."Posting Date", SalesInvLine."No.",
                SalesInvLine.Quantity, LineEligibleQty, SalesInvLine.Amount);
        end;
    end;

    local procedure AccumulateCrLine(
        SchemeHdr: Record "PTV Scheme Header";
        SchemeLine: Record "PTV Scheme Line";
        UseSpecificLine: Boolean;
        CustomerNo: Code[20];
        EffectiveMeasure: Enum "PTV Rebate Measure";
        GroupCode: Code[20];
        SalesCrLine: Record "Sales Cr.Memo Line";
        var TotalQty: Decimal;
        var TotalLitres: Decimal;
        var TotalKg: Decimal;
        var TotalEligibleQty: Decimal;
        var TotalGrossVal: Decimal;
        var TotalNetVal: Decimal;
        var LuxVal: Decimal;
        var PremVal: Decimal;
        var BudgVal: Decimal;
        RecordLines: Boolean;
        var NextTempNo: Integer;
        var TempApplied: Record "PTV Scheme Applied Entry" temporary)
    var
        Item: Record Item;
        PaintProduct: Record "PTV Paint Product";
        LineLitres: Decimal;
        LineKg: Decimal;
        LineEligibleQty: Decimal;
    begin
        if SchemeHdr."Location Filter" <> '' then
            if not GrowthPayGate.MatchesTextFilter(SalesCrLine."Location Code", SchemeHdr."Location Filter") then
                exit;
        if SchemeHdr."Exclude FOC Lines" and SalesCrLine."PTV FOC Item" then
            exit;
        if (SchemeHdr."Special Price Handling" <> SchemeHdr."Special Price Handling"::Allow) and
           (SalesCrLine."PTV Special Price" or SalesCrLine."PTV Tie-Up Discount")
        then
            exit;
        if SalesCrLine.Amount <= 0 then
            exit;
        if RecordLines and IsDocLineClaimed(SchemeHdr, TempApplied."Source Document Type"::"Sales Credit Memo", SalesCrLine."Document No.", SalesCrLine."Line No.") then
            exit;

        Item.SetLoadFields("Item Category Code", "PTV Product Code");
        if not Item.Get(SalesCrLine."No.") then
            exit;
        if not IsItemEligibleForScheme(SchemeHdr, SchemeLine, UseSpecificLine, SalesCrLine."No.", SalesCrLine."PTV Product Code", SalesCrLine."PTV Shade Code", SalesCrLine."PTV Pack Code", Item."Item Category Code") then
            exit;

        LineEligibleQty := GrowthPayGate.GetMeasuredQuantity(
            SalesCrLine."No.", SalesCrLine."Unit of Measure Code", SalesCrLine.Quantity, SalesCrLine."Quantity (Base)",
            EffectiveMeasure, GroupCode, LineLitres, LineKg);

        TotalQty -= SalesCrLine.Quantity;
        TotalLitres -= LineLitres;
        TotalKg -= LineKg;
        TotalEligibleQty -= LineEligibleQty;
        TotalGrossVal -= SalesCrLine."Amount Including VAT";
        TotalNetVal -= SalesCrLine.Amount;

        if PaintProduct.Get(SalesCrLine."PTV Product Code") then
            AccumulateSegment(PaintProduct."PTV Product Segment", -SalesCrLine.Amount, LuxVal, PremVal, BudgVal);

        if RecordLines then begin
            NextTempNo += 1;
            AddTempApplied(TempApplied, NextTempNo, SchemeHdr, CustomerNo, TempApplied."Source Document Type"::"Sales Credit Memo",
                SalesCrLine."Document No.", SalesCrLine."Line No.", SalesCrLine."Posting Date", SalesCrLine."No.",
                -SalesCrLine.Quantity, -LineEligibleQty, -SalesCrLine.Amount);
        end;
    end;

    local procedure IsItemEligibleForScheme(SchemeHdr: Record "PTV Scheme Header"; TargetLine: Record "PTV Scheme Line"; UseSpecificLine: Boolean; ItemNo: Code[20]; ProductCode: Code[20]; ShadeCode: Code[20]; PackCode: Code[20]; ItemCategoryCode: Code[20]): Boolean
    var
        ExcludeLine: Record "PTV Scheme Line";
        IncludeLine: Record "PTV Scheme Line";
        HasIncludes: Boolean;
    begin
        ExcludeLine.SetRange("Scheme Code", SchemeHdr.Code);
        ExcludeLine.SetRange("Line Type", ExcludeLine."Line Type"::Exclude);
        if ExcludeLine.FindSet() then
            repeat
                if GrowthPayGate.MatchesSchemeLine(ExcludeLine, ItemNo, ProductCode, ShadeCode, PackCode, ItemCategoryCode) then
                    exit(false);
            until ExcludeLine.Next() = 0;

        if UseSpecificLine then
            exit(GrowthPayGate.MatchesSchemeLine(TargetLine, ItemNo, ProductCode, ShadeCode, PackCode, ItemCategoryCode));

        IncludeLine.SetRange("Scheme Code", SchemeHdr.Code);
        IncludeLine.SetRange("Line Type", IncludeLine."Line Type"::Include);
        HasIncludes := not IncludeLine.IsEmpty();
        if not HasIncludes then
            exit(true);

        if IncludeLine.FindSet() then
            repeat
                if GrowthPayGate.MatchesSchemeLine(IncludeLine, ItemNo, ProductCode, ShadeCode, PackCode, ItemCategoryCode) then
                    exit(true);
            until IncludeLine.Next() = 0;

        exit(false);
    end;

    local procedure FindBestSlab(SchemeHdr: Record "PTV Scheme Header"; LineNo: Integer; Qty: Decimal; NetVal: Decimal; GrowthPct: Decimal; DefaultMinGrowthPct: Decimal; var BestSlab: Record "PTV Scheme Slab"; var GrowthOK: Boolean): Boolean
    var
        Slab: Record "PTV Scheme Slab";
        CandidateMinGrowth: Decimal;
        FoundAny: Boolean;
        MetricVal: Decimal;
        MatchesMetric: Boolean;
    begin
        GrowthOK := true;
        Slab.SetRange("Scheme Code", SchemeHdr.Code);
        Slab.SetRange("Scheme Line No.", LineNo);
        if not Slab.FindLast() then
            exit(false);

        repeat
            if (Slab."From Value" > 0) or (Slab."To Value" > 0) then begin
                MetricVal := NetVal;
                MatchesMetric := (MetricVal >= Slab."From Value") and ((Slab."To Value" = 0) or (MetricVal <= Slab."To Value"));
            end else begin
                MetricVal := Qty;
                MatchesMetric := (MetricVal >= Slab."From Quantity") and ((Slab."To Quantity" = 0) or (MetricVal <= Slab."To Quantity"));
            end;

            if MatchesMetric then begin
                CandidateMinGrowth := Slab."Min Growth %";
                if CandidateMinGrowth = 0 then
                    CandidateMinGrowth := DefaultMinGrowthPct;

                if (not SchemeHdr."Require Growth Check") or (GrowthPct >= CandidateMinGrowth) then begin
                    BestSlab := Slab;
                    GrowthOK := true;
                    exit(true);
                end;

                if not FoundAny then begin
                    BestSlab := Slab;
                    FoundAny := true;
                    GrowthOK := false;
                end;
            end else
                if FoundAny and (SchemeHdr."Growth Failure Action" = SchemeHdr."Growth Failure Action"::"Step Down") then
                    if ((Slab."From Value" > 0) and (NetVal >= Slab."From Value")) or ((Slab."From Quantity" > 0) and (Qty >= Slab."From Quantity")) then begin
                        CandidateMinGrowth := Slab."Min Growth %";
                        if CandidateMinGrowth = 0 then
                            CandidateMinGrowth := DefaultMinGrowthPct;
                        if GrowthPct >= CandidateMinGrowth then begin
                            BestSlab := Slab;
                            GrowthOK := true;
                            exit(true);
                        end;
                    end;
        until Slab.Next(-1) = 0;

        exit(FoundAny);
    end;

    local procedure ComputeLinePayout(Slab: Record "PTV Scheme Slab"; EligibleQty: Decimal; NetVal: Decimal; var RebateAmt: Decimal; var FOCQty: Decimal)
    var
        ExcessQty: Decimal;
    begin
        RebateAmt := 0;
        FOCQty := 0;
        case Slab."Discount Type" of
            Slab."Discount Type"::"Rate per Unit":
                RebateAmt := Round(EligibleQty * Slab."Rate per Unit", 0.01);
            Slab."Discount Type"::Percentage:
                RebateAmt := Round(NetVal * Slab."Discount %" / 100, 0.01);
            Slab."Discount Type"::"Fixed Amount", Slab."Discount Type"::"Trip or Fixed CN":
                RebateAmt := Round(Slab."Discount Amount", 0.01);
            Slab."Discount Type"::"FOC Quantity":
                begin
                    if Slab."Proportional FOC" and (Slab."From Quantity" > 0) then
                        FOCQty := Round(EligibleQty / Slab."From Quantity", 1, '<') * Slab."FOC Quantity"
                    else
                        FOCQty := Slab."FOC Quantity";

                    if (Slab."Incremental Qty" > 0) and (Slab."Incremental FOC Qty" > 0) then begin
                        ExcessQty := EligibleQty - Slab."From Quantity";
                        if ExcessQty > 0 then
                            FOCQty += Round(ExcessQty / Slab."Incremental Qty", 1, '<') * Slab."Incremental FOC Qty";
                    end;
                    FOCQty := Round(FOCQty, 1, '<');
                end;
        end;
    end;

    local procedure ComputeValueRebatePayout(Slab: Record "PTV Scheme Slab"; NetVal: Decimal; var BaseRebate: Decimal; var IncrBonus: Decimal)
    var
        BaseThreshold: Decimal;
        Multiples: Decimal;
        Excess: Decimal;
        Steps: Decimal;
    begin
        BaseRebate := 0;
        IncrBonus := 0;
        case Slab."Discount Type" of
            Slab."Discount Type"::Percentage:
                BaseRebate := Round(NetVal * Slab."Discount %" / 100, 0.01);
            Slab."Discount Type"::"Fixed Amount", Slab."Discount Type"::"Trip or Fixed CN":
                begin
                    if Slab."Allow Base Multiples" and (Slab."Multiple Base Value" > 0) then begin
                        Multiples := Round(NetVal / Slab."Multiple Base Value", 1, '<');
                        if Multiples < 1 then
                            Multiples := 1;
                        BaseRebate := Round(Multiples * Slab."Discount Amount", 0.01);
                    end else
                        BaseRebate := Round(Slab."Discount Amount", 0.01);

                    if (Slab."Incremental Step Value" > 0) and (Slab."Incremental Bonus Amount" > 0) then begin
                        if Slab."Multiple Base Value" > 0 then
                            BaseThreshold := Slab."Multiple Base Value"
                        else
                            BaseThreshold := Slab."From Value";
                        Excess := NetVal - BaseThreshold;
                        if Excess > 0 then begin
                            Steps := Round(Excess / Slab."Incremental Step Value", 1, '<');
                            IncrBonus := Round(Steps * Slab."Incremental Bonus Amount", 0.01);
                        end;
                    end;
                end;
        end;
    end;

    local procedure HasEntitlementForPeriod(SchemeCode: Code[20]; CustomerNo: Code[20]; PeriodStart: Date; PeriodEnd: Date; LineNo: Integer): Boolean
    var
        Entitlement: Record "PTV Scheme Entitlement";
    begin
        Entitlement.SetRange("Scheme Code", SchemeCode);
        Entitlement.SetRange("Customer No.", CustomerNo);
        Entitlement.SetRange("Period Start Date", PeriodStart);
        Entitlement.SetRange("Period End Date", PeriodEnd);
        Entitlement.SetRange("Scheme Line No.", LineNo);
        exit(not Entitlement.IsEmpty());
    end;

    local procedure IsDocLineClaimed(SchemeHdr: Record "PTV Scheme Header"; DocType: Enum "PTV Scheme Applied Doc Type"; DocNo: Code[20]; LineNo: Integer): Boolean
    var
        AppliedEntry: Record "PTV Scheme Applied Entry";
        PostedApplied: Record "PTV Posted Scheme Applied";
    begin
        if SchemeHdr."Exclusion Group" = '' then
            exit(false);
        AppliedEntry.SetRange("Source Document Type", DocType);
        AppliedEntry.SetRange("Document No.", DocNo);
        AppliedEntry.SetRange("Document Line No.", LineNo);
        AppliedEntry.SetRange("Exclusion Group", SchemeHdr."Exclusion Group");
        if not AppliedEntry.IsEmpty() then
            exit(true);

        PostedApplied.SetRange("Source Document Type", DocType);
        PostedApplied.SetRange("Document No.", DocNo);
        PostedApplied.SetRange("Document Line No.", LineNo);
        PostedApplied.SetRange("Exclusion Group", SchemeHdr."Exclusion Group");
        exit(not PostedApplied.IsEmpty());
    end;

    local procedure AccumulateSegment(Segment: Enum "PTV Product Segment"; Amount: Decimal; var LuxVal: Decimal; var PremVal: Decimal; var BudgVal: Decimal)
    begin
        case Segment of
            Segment::Luxury:
                LuxVal += Amount;
            Segment::Premium:
                PremVal += Amount;
            Segment::"Budget & Economy":
                BudgVal += Amount;
        end;
    end;

    local procedure AddTempApplied(var TempApplied: Record "PTV Scheme Applied Entry" temporary; EntryNo: Integer; SchemeHdr: Record "PTV Scheme Header"; CustomerNo: Code[20]; DocType: Enum "PTV Scheme Applied Doc Type"; DocNo: Code[20]; LineNo: Integer; PostingDate: Date; ItemNo: Code[20]; Qty: Decimal; EligibleQty: Decimal; NetAmt: Decimal)
    begin
        TempApplied.Init();
        TempApplied."Entry No." := EntryNo;
        TempApplied."Scheme Code" := SchemeHdr.Code;
        TempApplied."Exclusion Group" := SchemeHdr."Exclusion Group";
        TempApplied."Customer No." := CustomerNo;
        TempApplied."Source Document Type" := DocType;
        TempApplied."Document No." := DocNo;
        TempApplied."Document Line No." := LineNo;
        TempApplied."Posting Date" := PostingDate;
        TempApplied."Item No." := ItemNo;
        TempApplied.Quantity := Qty;
        TempApplied."Eligible Qty (Kg/Ltr)" := EligibleQty;
        TempApplied."Net Amount" := NetAmt;
        TempApplied.Insert();
    end;
}
