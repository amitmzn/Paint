codeunit 77201 "PTV Scheme Calc Engine"
{
    Permissions = tabledata "PTV Scheme Entitlement" = RIMD,
                  tabledata "PTV Scheme Applied Entry" = RIMD;
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
    begin
        if SchemeHdr."Exclusion Group" <> '' then begin
            SchemeHdr.TestField(Status, SchemeHdr.Status::Released);
            exit(CalculateExclusionGroup(SchemeHdr."Exclusion Group"));
        end;
        exit(CalculateSingleScheme(SchemeHdr));
    end;

    local procedure CalculateSingleScheme(var SchemeHdr: Record "PTV Scheme Header"): Integer
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
        SchemeHdr.TestField("Scheme Type");
        if SchemeHdr.Status <> SchemeHdr.Status::Released then
            Error(NotReleasedErr, SchemeHdr.Code);

        SerializeCalculation();
        SchemeHdr.Get(SchemeHdr.Code);
        if SchemeHdr.Status <> SchemeHdr.Status::Released then
            Error(NotReleasedErr, SchemeHdr.Code);
        ValidateSchemeSlabs(SchemeHdr);
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

    procedure CalculateExclusionGroup(GroupCode: Code[20]): Integer
    var
        Header: Record "PTV Scheme Header";
        CountCreated: Integer;
    begin
        if GroupCode = '' then
            exit(0);
        SerializeCalculation();
        Header.SetCurrentKey("Exclusion Group", "Claim Priority", Code);
        Header.SetRange("Exclusion Group", GroupCode);
        Header.SetRange(Status, Header.Status::Released);
        if Header.FindSet() then begin
            repeat
                ClearOpenEntitlements(Header.Code);
            until Header.Next() = 0;
            Header.FindSet();
            repeat
                CountCreated += CalculateSingleScheme(Header);
            until Header.Next() = 0;
        end;
        exit(CountCreated);
    end;

    local procedure SerializeCalculation()
    var
        Header: Record "PTV Scheme Header";
    begin
        Header.LockTable();
        if Header.FindFirst() then
            Header.TestField(Code);
    end;

    procedure ValidateSchemeSlabs(Header: Record "PTV Scheme Header")
    var
        Line: Record "PTV Scheme Line";
        Slab: Record "PTV Scheme Slab";
        MissingSlabErr: Label 'Scheme %1 has no reward slabs for line %2. Open the slabs for that line and correct their links.', Comment = '%1 = scheme code, %2 = line number (0 = header)';
        InvalidLineErr: Label 'Scheme %1 slab %2 refers to missing or excluded line %3.', Comment = '%1 = scheme code, %2 = slab number, %3 = line number';
        InvalidSlabErr: Label 'Scheme %1, line %2, slab %3 has invalid bounds or reward setup.', Comment = '%1 = scheme code, %2 = line number, %3 = slab number';
    begin
        Slab.SetRange("Scheme Code", Header.Code);
        if Header."Scheme Type" = Header."Scheme Type"::"Value Rebate" then begin
            Slab.SetRange("Scheme Line No.", 0);
            if Slab.IsEmpty() then
                Error(MissingSlabErr, Header.Code, 0);
            Slab.SetRange("Scheme Line No.");
        end else begin
            Line.SetRange("Scheme Code", Header.Code);
            Line.SetRange("Line Type", Line."Line Type"::Include);
            if not Line.FindSet() then
                Error(MissingSlabErr, Header.Code, 0);
            repeat
                Slab.SetRange("Scheme Line No.", Line."Line No.");
                if Header."Scheme Type" = Header."Scheme Type"::"FOC Quantity" then
                    Slab.SetRange("Discount Type", Slab."Discount Type"::"FOC Quantity");
                if Slab.IsEmpty() then
                    Error(MissingSlabErr, Header.Code, Line."Line No.");
            until Line.Next() = 0;
            Slab.SetRange("Scheme Line No.");
            Slab.SetRange("Discount Type");
        end;
        if Slab.FindSet() then
            repeat
                if Slab."Scheme Line No." <> 0 then begin
                    if not Line.Get(Header.Code, Slab."Scheme Line No.") then
                        Error(InvalidLineErr, Header.Code, Slab."Slab No.", Slab."Scheme Line No.");
                    if Line."Line Type" <> Line."Line Type"::Include then
                        Error(InvalidLineErr, Header.Code, Slab."Slab No.", Slab."Scheme Line No.");
                end;
                if ((Slab."To Quantity" > 0) and (Slab."To Quantity" < Slab."From Quantity")) or
                   ((Slab."To Value" > 0) and (Slab."To Value" < Slab."From Value")) or
                   ((Slab."Discount Type" = Slab."Discount Type"::"FOC Quantity") and
                    ((Slab."FOC Item No." = '') or (Slab."FOC Quantity" <= 0) or
                     (Slab."Proportional FOC" and (Slab."FOC Buy Quantity" <= 0) and (Slab."From Quantity" <= 0))))
                then
                    Error(InvalidSlabErr, Header.Code, Slab."Scheme Line No.", Slab."Slab No.");
            until Slab.Next() = 0;
    end;

    local procedure ProcessCustomerPeriod(SchemeHdr: Record "PTV Scheme Header"; Customer: Record Customer; PeriodStart: Date; PeriodEnd: Date): Integer
    var
        DummyLine: Record "PTV Scheme Line";
        TempApplied: Record "PTV Scheme Applied Entry" temporary;
        Qty: Decimal;
        Litres: Decimal;
        Kg: Decimal;
        EligibleQty: Decimal;
        GrossVal: Decimal;
        NetVal: Decimal;
        LuxVal: Decimal;
        PremVal: Decimal;
        BudgVal: Decimal;
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

        if (SchemeHdr."Minimum Net Value" > 0) or (SchemeHdr."Minimum Quantity" > 0) or
           SchemeHdr."Use Customer Targets" or (SchemeHdr."Scheme Type" = SchemeHdr."Scheme Type"::"FOC Quantity")
        then begin
            AggregateSalesForPeriod(
                SchemeHdr, DummyLine, false, Customer."No.", PeriodStart, PeriodEnd,
                Qty, Litres, Kg, EligibleQty, GrossVal, NetVal, LuxVal, PremVal, BudgVal, true, true, TempApplied);
            if (NetVal < SchemeHdr."Minimum Net Value") or (EligibleQty < SchemeHdr."Minimum Quantity") then
                exit(0);
        end;
        exit(CalculateLineBasedEntitlements(SchemeHdr, Customer, PeriodStart, PeriodEnd, ValueBasis(SchemeHdr, GrossVal, NetVal), EligibleQty));
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
                SchemeHdr."Evaluation Period"::Weekly:
                    CurrEnd := CalcDate('<CW>', CurrStart);
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

    local procedure CalculateLineBasedEntitlements(SchemeHdr: Record "PTV Scheme Header"; Customer: Record Customer; PeriodStart: Date; PeriodEnd: Date; QualificationValue: Decimal; QualificationQty: Decimal): Integer
    var
        SchemeLine: Record "PTV Scheme Line";
        CreatedCount: Integer;
    begin
        SchemeLine.SetRange("Scheme Code", SchemeHdr.Code);
        SchemeLine.SetRange("Line Type", SchemeLine."Line Type"::Include);
        if not SchemeLine.FindSet() then
            exit(0);

        repeat
            if ProcessSingleSchemeLine(SchemeHdr, SchemeLine, Customer, PeriodStart, PeriodEnd, QualificationValue, QualificationQty) then
                CreatedCount += 1;
        until SchemeLine.Next() = 0;

        exit(CreatedCount);
    end;

    local procedure ProcessSingleSchemeLine(SchemeHdr: Record "PTV Scheme Header"; SchemeLine: Record "PTV Scheme Line"; Customer: Record Customer; PeriodStart: Date; PeriodEnd: Date; QualificationValue: Decimal; QualificationQty: Decimal): Boolean
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
        PriorGrossVal: Decimal;
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
            Qty, Litres, Kg, EligibleQty, GrossVal, NetVal, LuxVal, PremVal, BudgVal, true, false, TempApplied);

        if (EligibleQty <= 0) and (NetVal <= 0) then
            exit(false);
        if (SchemeLine."Minimum Quantity" > 0) and (EligibleQty < SchemeLine."Minimum Quantity") then
            exit(false);
        if (ValueBasis(SchemeHdr, GrossVal, NetVal) < SchemeLine."Minimum Value") or
           (ValueBasis(SchemeHdr, GrossVal, NetVal) < SchemeLine."Target Value") or
           (EligibleQty < SchemeLine."Target Quantity")
        then
            exit(false);

        GetPriorSales(SchemeHdr, SchemeLine, true, Customer."No.", PriorStart, PriorEnd, PriorQty, PriorGrossVal, PriorVal);

        GrowthPct := GrowthPayGate.ComputeGrowthPct(EligibleQty, PriorQty);
        MinGrowthPct := SchemeLine."Min Growth %";
        if MinGrowthPct = 0 then
            MinGrowthPct := SchemeHdr."Default Min Growth %";

        if not FindBestSlab(SchemeHdr, SchemeLine."Line No.", Customer."No.", EligibleQty, ValueBasis(SchemeHdr, GrossVal, NetVal), QualificationValue, QualificationQty, GrowthPct, MinGrowthPct, Slab, GrowthOK) then
            exit(false);

        ComputeLinePayout(Slab, EligibleQty, ValueBasis(SchemeHdr, GrossVal, NetVal), RebateAmt, FOCQty);
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
        if not GrowthOK then begin
            Entitlement.Status := Entitlement.Status::Rejected;
            Entitlement."Rejection Reason" := StrSubstNo('Growth %1% below minimum %2%.', GrowthPct, MinGrowthPct);
        end;
        SetEstimatedFOCCost(Entitlement);
        Entitlement.Insert(true);

        if GrowthOK and TempApplied.FindSet() then
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
        PriorGrossVal: Decimal;
        GrowthPct: Decimal;
        GrowthOK: Boolean;
        PayCleared: Boolean;
        UnpaidAmt: Decimal;
        BaseRebate: Decimal;
        FOCQty: Decimal;
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
            Qty, Litres, Kg, EligibleQty, GrossVal, NetVal, LuxVal, PremVal, BudgVal, true, false, TempApplied);

        if (ValueBasis(SchemeHdr, GrossVal, NetVal) <= 0) and (EligibleQty <= 0) then
            exit(false);
        if (SchemeHdr."Minimum Net Value" > 0) and (NetVal < SchemeHdr."Minimum Net Value") then
            exit(false);

        if EligibleQty < SchemeHdr."Minimum Quantity" then
            exit(false);

        GetPriorSales(SchemeHdr, DummyLine, false, Customer."No.", PriorStart, PriorEnd, PriorQty, PriorGrossVal, PriorVal);

        GrowthPct := GrowthPayGate.ComputeGrowthPct(ValueBasis(SchemeHdr, GrossVal, NetVal), ValueBasis(SchemeHdr, PriorGrossVal, PriorVal));

        if not FindBestSlab(SchemeHdr, 0, Customer."No.", EligibleQty, ValueBasis(SchemeHdr, GrossVal, NetVal), ValueBasis(SchemeHdr, GrossVal, NetVal), EligibleQty, GrowthPct, SchemeHdr."Default Min Growth %", Slab, GrowthOK) then
            exit(false);

        if Slab."Discount Type" = Slab."Discount Type"::"FOC Quantity" then
            ComputeLinePayout(Slab, EligibleQty, ValueBasis(SchemeHdr, GrossVal, NetVal), BaseRebate, FOCQty)
        else
            ComputeValueRebatePayout(Slab, ValueBasis(SchemeHdr, GrossVal, NetVal), BaseRebate, IncrBonus);
        if (BaseRebate + IncrBonus = 0) and (FOCQty = 0) and (Slab."Trip Description" = '') then
            exit(false);

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
        if Slab."Discount Type" = Slab."Discount Type"::"FOC Quantity" then begin
            Entitlement."Reward Choice" := Entitlement."Reward Choice"::"FOC Order";
            Entitlement."FOC Item No." := Slab."FOC Item No.";
            Entitlement."FOC Unit of Measure" := Slab."FOC Unit of Measure";
            Entitlement."FOC Quantity" := FOCQty;
        end;
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
        if not GrowthOK then begin
            Entitlement.Status := Entitlement.Status::Rejected;
            Entitlement."Rejection Reason" := StrSubstNo('Growth %1% below slab minimum %2%.', GrowthPct, Slab."Min Growth %");
        end;
        SetEstimatedFOCCost(Entitlement);
        Entitlement.Insert(true);

        if GrowthOK and TempApplied.FindSet() then
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

    local procedure SetEstimatedFOCCost(var Entitlement: Record "PTV Scheme Entitlement")
    var
        Item: Record Item;
        ItemUOM: Record "Item Unit of Measure";
        RewardUOM: Code[10];
        BaseFactor: Decimal;
    begin
        if (Entitlement."FOC Quantity" <= 0) or not Item.Get(Entitlement."FOC Item No.") then
            exit;
        RewardUOM := Entitlement."FOC Unit of Measure";
        if RewardUOM = '' then
            RewardUOM := Item."Sales Unit of Measure";
        BaseFactor := 1;
        if (RewardUOM <> '') and ItemUOM.Get(Item."No.", RewardUOM) then
            BaseFactor := ItemUOM."Qty. per Unit of Measure";
        Entitlement."Estimated FOC Cost" := Round(Entitlement."FOC Quantity" * BaseFactor * Item."Unit Cost", 0.01);
    end;

    local procedure GetPriorSales(Header: Record "PTV Scheme Header"; Line: Record "PTV Scheme Line"; UseLine: Boolean; CustomerNo: Code[20]; StartDate: Date; EndDate: Date; var EligibleQty: Decimal; var GrossValue: Decimal; var NetValue: Decimal)
    var
        TempApplied: Record "PTV Scheme Applied Entry" temporary;
        Qty: Decimal;
        Litres: Decimal;
        Kg: Decimal;
        Luxury: Decimal;
        Premium: Decimal;
        Budget: Decimal;
    begin
        AggregateSalesForPeriod(Header, Line, UseLine, CustomerNo, StartDate, EndDate, Qty, Litres, Kg, EligibleQty,
            GrossValue, NetValue, Luxury, Premium, Budget, false, false, TempApplied);
    end;

    local procedure ValueBasis(Header: Record "PTV Scheme Header"; GrossValue: Decimal; NetValue: Decimal): Decimal
    begin
        if Header."Calculation Basis" = Header."Calculation Basis"::"Gross Sales Value" then
            exit(GrossValue);
        exit(NetValue);
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
        DealerQualification: Boolean;
        var TempApplied: Record "PTV Scheme Applied Entry" temporary)
    var
        SalesInvLine: Record "Sales Invoice Line";
        SalesCrLine: Record "Sales Cr.Memo Line";
        ProductGroup: Record "PTV Scheme Product Group";
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

        if (EffectiveMeasure = EffectiveMeasure::Auto) and (GroupCode <> '') then
            if ProductGroup.Get(GroupCode) then
                EffectiveMeasure := ProductGroup."Rebate Measure";

        case SchemeHdr."Calculation Basis" of
            SchemeHdr."Calculation Basis"::"Sales Quantity":
                if EffectiveMeasure = EffectiveMeasure::Auto then
                    EffectiveMeasure := EffectiveMeasure::"Base UOM";
            SchemeHdr."Calculation Basis"::"Sales Volume Litres":
                if EffectiveMeasure = EffectiveMeasure::Auto then
                    EffectiveMeasure := EffectiveMeasure::Litres;
            SchemeHdr."Calculation Basis"::"Sales Weight Kg":
                if EffectiveMeasure = EffectiveMeasure::Auto then
                    EffectiveMeasure := EffectiveMeasure::Kilograms;
        end;

        SalesInvLine.SetCurrentKey("Sell-to Customer No.", "Posting Date", Type);
        SalesInvLine.SetRange("Sell-to Customer No.", CustomerNo);
        SalesInvLine.SetRange("Posting Date", PeriodStart, PeriodEnd);
        SalesInvLine.SetRange(Type, SalesInvLine.Type::Item);
        SalesInvLine.SetLoadFields(
            "Document No.", "Line No.", "No.", "Posting Date", Quantity, "Quantity (Base)",
            "Unit of Measure Code", Amount, "Line Discount Amount", "Inv. Discount Amount", "Location Code",
            "PTV Product Code", "PTV Shade Code", "PTV Pack Code", "PTV FOC Item", "PTV Special Price", "PTV Tie-Up Discount",
            "PTV Quantity Litres", "PTV Litres per Base Unit");
        if SalesInvLine.FindSet() then
            repeat
                AccumulateInvLine(
                    SchemeHdr, SchemeLine, UseSpecificLine, CustomerNo, EffectiveMeasure, GroupCode, SalesInvLine,
                    TotalQty, TotalLitres, TotalKg, TotalEligibleQty, TotalGrossVal, TotalNetVal, LuxVal, PremVal, BudgVal,
                    RecordLines, DealerQualification, NextTempNo, TempApplied);
            until SalesInvLine.Next() = 0;

        SalesCrLine.SetCurrentKey("Sell-to Customer No.", "Posting Date", Type);
        SalesCrLine.SetRange("Sell-to Customer No.", CustomerNo);
        SalesCrLine.SetRange("Posting Date", PeriodStart, PeriodEnd);
        SalesCrLine.SetRange(Type, SalesCrLine.Type::Item);
        SalesCrLine.SetLoadFields(
            "Document No.", "Line No.", "No.", "Posting Date", Quantity, "Quantity (Base)",
            "Unit of Measure Code", Amount, "Line Discount Amount", "Inv. Discount Amount", "Location Code",
            "PTV Product Code", "PTV Shade Code", "PTV Pack Code", "PTV FOC Item", "PTV Special Price", "PTV Tie-Up Discount",
            "PTV Quantity Litres", "PTV Litres per Base Unit");
        if SalesCrLine.FindSet() then
            repeat
                AccumulateCrLine(
                    SchemeHdr, SchemeLine, UseSpecificLine, CustomerNo, EffectiveMeasure, GroupCode, SalesCrLine,
                    TotalQty, TotalLitres, TotalKg, TotalEligibleQty, TotalGrossVal, TotalNetVal, LuxVal, PremVal, BudgVal,
                    RecordLines, DealerQualification, NextTempNo, TempApplied);
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
        DealerQualification: Boolean;
        var NextTempNo: Integer;
        var TempApplied: Record "PTV Scheme Applied Entry" temporary)
    var
        UOMMgt: Codeunit "PTV UOM Mgt";
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
        if (SalesInvLine.Amount <= 0) and
           ((SchemeHdr."Calculation Basis" <> SchemeHdr."Calculation Basis"::"Gross Sales Value") or
            (SalesInvLine.Amount + SalesInvLine."Line Discount Amount" + SalesInvLine."Inv. Discount Amount" <= 0))
        then
            exit;
        if RecordLines and IsDocLineClaimed(SchemeHdr, TempApplied."Source Document Type"::"Sales Invoice", SalesInvLine."Document No.", SalesInvLine."Line No.") then
            exit;

        Item.SetLoadFields("Item Category Code", "PTV Product Code");
        if not Item.Get(SalesInvLine."No.") then
            exit;
        if not IsItemEligibleForScheme(SchemeHdr, SchemeLine, UseSpecificLine, SalesInvLine."No.", SalesInvLine."PTV Product Code", SalesInvLine."PTV Shade Code", SalesInvLine."PTV Pack Code", Item."Item Category Code", Item."Item Disc. Group", SalesInvLine."Unit of Measure Code", DealerQualification) then
            exit;

        LineEligibleQty := GrowthPayGate.GetMeasuredQuantity(
            SalesInvLine."No.", SalesInvLine."Unit of Measure Code", SalesInvLine.Quantity, SalesInvLine."Quantity (Base)",
            UOMMgt.PostedInvoiceLitres(SalesInvLine), EffectiveMeasure, GroupCode, LineLitres, LineKg);

        TotalQty += SalesInvLine.Quantity;
        TotalLitres += LineLitres;
        TotalKg += LineKg;
        TotalEligibleQty += LineEligibleQty;
        TotalGrossVal += (SalesInvLine.Amount + SalesInvLine."Line Discount Amount" + SalesInvLine."Inv. Discount Amount");
        TotalNetVal += SalesInvLine.Amount;

        if PaintProduct.Get(SalesInvLine."PTV Product Code") then
            AccumulateSegment(PaintProduct."PTV Product Segment", SalesInvLine.Amount, LuxVal, PremVal, BudgVal);

        if RecordLines and not DealerQualification then begin
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
        DealerQualification: Boolean;
        var NextTempNo: Integer;
        var TempApplied: Record "PTV Scheme Applied Entry" temporary)
    var
        UOMMgt: Codeunit "PTV UOM Mgt";
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
        if (SalesCrLine.Amount <= 0) and
           ((SchemeHdr."Calculation Basis" <> SchemeHdr."Calculation Basis"::"Gross Sales Value") or
            (SalesCrLine.Amount + SalesCrLine."Line Discount Amount" + SalesCrLine."Inv. Discount Amount" <= 0))
        then
            exit;
        if RecordLines and IsDocLineClaimed(SchemeHdr, TempApplied."Source Document Type"::"Sales Credit Memo", SalesCrLine."Document No.", SalesCrLine."Line No.") then
            exit;

        Item.SetLoadFields("Item Category Code", "PTV Product Code");
        if not Item.Get(SalesCrLine."No.") then
            exit;
        if not IsItemEligibleForScheme(SchemeHdr, SchemeLine, UseSpecificLine, SalesCrLine."No.", SalesCrLine."PTV Product Code", SalesCrLine."PTV Shade Code", SalesCrLine."PTV Pack Code", Item."Item Category Code", Item."Item Disc. Group", SalesCrLine."Unit of Measure Code", DealerQualification) then
            exit;

        LineEligibleQty := GrowthPayGate.GetMeasuredQuantity(
            SalesCrLine."No.", SalesCrLine."Unit of Measure Code", SalesCrLine.Quantity, SalesCrLine."Quantity (Base)",
            UOMMgt.PostedCreditMemoLitres(SalesCrLine), EffectiveMeasure, GroupCode, LineLitres, LineKg);

        TotalQty -= SalesCrLine.Quantity;
        TotalLitres -= LineLitres;
        TotalKg -= LineKg;
        TotalEligibleQty -= LineEligibleQty;
        TotalGrossVal -= (SalesCrLine.Amount + SalesCrLine."Line Discount Amount" + SalesCrLine."Inv. Discount Amount");
        TotalNetVal -= SalesCrLine.Amount;

        if PaintProduct.Get(SalesCrLine."PTV Product Code") then
            AccumulateSegment(PaintProduct."PTV Product Segment", -SalesCrLine.Amount, LuxVal, PremVal, BudgVal);

        if RecordLines and not DealerQualification then begin
            NextTempNo += 1;
            AddTempApplied(TempApplied, NextTempNo, SchemeHdr, CustomerNo, TempApplied."Source Document Type"::"Sales Credit Memo",
                SalesCrLine."Document No.", SalesCrLine."Line No.", SalesCrLine."Posting Date", SalesCrLine."No.",
                -SalesCrLine.Quantity, -LineEligibleQty, -SalesCrLine.Amount);
        end;
    end;

    local procedure IsItemEligibleForScheme(SchemeHdr: Record "PTV Scheme Header"; TargetLine: Record "PTV Scheme Line"; UseSpecificLine: Boolean; ItemNo: Code[20]; ProductCode: Code[20]; ShadeCode: Code[20]; PackCode: Code[20]; ItemCategoryCode: Code[20]; ItemDiscountGroup: Code[20]; SalesUOM: Code[10]; DealerQualification: Boolean): Boolean
    var
        ExcludeLine: Record "PTV Scheme Line";
        IncludeLine: Record "PTV Scheme Line";
        HasIncludes: Boolean;
    begin
        ExcludeLine.SetRange("Scheme Code", SchemeHdr.Code);
        ExcludeLine.SetRange("Line Type", ExcludeLine."Line Type"::Exclude);
        if ExcludeLine.FindSet() then
            repeat
                if GrowthPayGate.MatchesSchemeLine(ExcludeLine, ItemNo, ProductCode, ShadeCode, PackCode, ItemCategoryCode, ItemDiscountGroup, SalesUOM) then
                    exit(false);
            until ExcludeLine.Next() = 0;

        if DealerQualification then
            exit(true);
        if UseSpecificLine then
            exit(GrowthPayGate.MatchesSchemeLine(TargetLine, ItemNo, ProductCode, ShadeCode, PackCode, ItemCategoryCode, ItemDiscountGroup, SalesUOM));

        IncludeLine.SetRange("Scheme Code", SchemeHdr.Code);
        IncludeLine.SetRange("Line Type", IncludeLine."Line Type"::Include);
        HasIncludes := not IncludeLine.IsEmpty();
        if not HasIncludes then
            exit(true);

        if IncludeLine.FindSet() then
            repeat
                if GrowthPayGate.MatchesSchemeLine(IncludeLine, ItemNo, ProductCode, ShadeCode, PackCode, ItemCategoryCode, ItemDiscountGroup, SalesUOM) then
                    exit(true);
            until IncludeLine.Next() = 0;

        exit(false);
    end;

    local procedure FindBestSlab(SchemeHdr: Record "PTV Scheme Header"; LineNo: Integer; CustomerNo: Code[20]; Qty: Decimal; SalesValue: Decimal; QualificationValue: Decimal; QualificationQty: Decimal; GrowthPct: Decimal; DefaultMinGrowthPct: Decimal; var BestSlab: Record "PTV Scheme Slab"; var GrowthOK: Boolean): Boolean
    var
        Slab: Record "PTV Scheme Slab";
        TierRank: Integer;
        BestTierRank: Integer;
        CustomerSpecific: Boolean;
        BestCustomerSpecific: Boolean;
        MinGrowth: Decimal;
        OverrideGrowth: Decimal;
        FloorValue: Decimal;
        BestFloor: Decimal;
        Metric: Decimal;
        Ceiling: Decimal;
        Eligible: Boolean;
        Found: Boolean;
        MatchedSlab: Boolean;
        QuantityMatches: Boolean;
        AllowStepDown: Boolean;
    begin
        Slab.SetRange("Scheme Code", SchemeHdr.Code);
        Slab.SetRange("Scheme Line No.", LineNo);
        if SchemeHdr."Scheme Type" = SchemeHdr."Scheme Type"::"FOC Quantity" then
            Slab.SetRange("Discount Type", Slab."Discount Type"::"FOC Quantity");
        if not Slab.FindSet() then
            exit(false);

        AllowStepDown := SchemeHdr."Require Growth Check" and
            (SchemeHdr."Growth Failure Action" = SchemeHdr."Growth Failure Action"::"Step Down");
        repeat
            if ((Slab."Customer No." = '') or (Slab."Customer No." = CustomerNo)) and
               GetTierRank(SchemeHdr, CustomerNo, Slab."Qualification Tier Code", QualificationValue, QualificationQty, TierRank, OverrideGrowth)
            then begin
                if (Slab."From Value" > 0) or (Slab."To Value" > 0) then begin
                    Metric := SalesValue;
                    FloorValue := Slab."From Value";
                    Ceiling := Slab."To Value";
                    QuantityMatches := (Qty >= Slab."From Quantity") and
                        ((Slab."To Quantity" = 0) or (Qty <= Slab."To Quantity"));
                end else begin
                    QuantityMatches := true;
                    Metric := Qty;
                    FloorValue := Slab."From Quantity";
                    Ceiling := Slab."To Quantity";
                end;
                CustomerSpecific := Slab."Customer No." <> '';
                MinGrowth := Slab."Min Growth %";
                if MinGrowth = 0 then
                    MinGrowth := DefaultMinGrowthPct;
                if OverrideGrowth > 0 then
                    MinGrowth := OverrideGrowth;
                Eligible := (not SchemeHdr."Require Growth Check") or (GrowthPct >= MinGrowth);
                if QuantityMatches and (Metric >= FloorValue) and ((Ceiling = 0) or (Metric <= Ceiling)) then
                    MatchedSlab := true;
                if QuantityMatches and (Metric >= FloorValue) and ((Ceiling = 0) or (Metric <= Ceiling) or (Eligible and AllowStepDown))
                then
                    if IsBetterSlab(Found, Eligible, GrowthOK, TierRank, BestTierRank, CustomerSpecific, BestCustomerSpecific,
                         FloorValue, BestFloor, Slab."Slab No.", BestSlab."Slab No.")
                    then begin
                        Found := true;
                        BestSlab := Slab;
                        BestTierRank := TierRank;
                        BestCustomerSpecific := CustomerSpecific;
                        BestFloor := FloorValue;
                        GrowthOK := Eligible;
                    end;
            end;
        until Slab.Next() = 0;
        exit(Found and MatchedSlab);
    end;

    local procedure IsBetterSlab(Found: Boolean; Eligible: Boolean; BestEligible: Boolean; TierRank: Integer; BestTierRank: Integer; CustomerSpecific: Boolean; BestCustomerSpecific: Boolean; FloorValue: Decimal; BestFloor: Decimal; SlabNo: Integer; BestSlabNo: Integer): Boolean
    begin
        if not Found then
            exit(true);
        if Eligible <> BestEligible then
            exit(Eligible);
        if TierRank <> BestTierRank then
            exit(TierRank > BestTierRank);
        if CustomerSpecific <> BestCustomerSpecific then
            exit(CustomerSpecific);
        if FloorValue <> BestFloor then
            exit(FloorValue > BestFloor);
        exit(SlabNo > BestSlabNo);
    end;

    local procedure GetTierRank(Header: Record "PTV Scheme Header"; CustomerNo: Code[20]; TierCode: Code[20]; SalesValue: Decimal; Quantity: Decimal; var Rank: Integer; var OverrideGrowth: Decimal): Boolean
    var
        Tier: Record "PTV Qualification Tier";
        Target: Record "PTV Scheme Customer Target";
        MinValue: Decimal;
        MinQuantity: Decimal;
        Scale: Decimal;
        HasTarget: Boolean;
    begin
        Rank := 0;
        OverrideGrowth := 0;
        if TierCode = '' then begin
            if Header."Use Customer Targets" and Header."Exclude If No Target" then
                exit(GetCustomerTarget(Header.Code, CustomerNo, '', Target));
            exit(true);
        end;
        if not Tier.Get(TierCode) then
            exit(false);
        if not Tier.Active then
            exit(false);

        if Header."Use Customer Targets" then
            HasTarget := GetCustomerTarget(Header.Code, CustomerNo, TierCode, Target);
        if Header."Use Customer Targets" and Header."Exclude If No Target" and not HasTarget then
            exit(false);
        if Tier."Is Base Tier" then
            exit(true);

        Rank := Tier.Sequence;
        MinValue := Tier."Default Min Value";
        MinQuantity := Tier."Default Min Quantity";
        if MinValue = 0 then
            MinValue := Header."Default Target Value";
        if HasTarget then begin
            Scale := Target."Threshold %" / 100;
            if Target."Target Value" > 0 then
                MinValue := Target."Target Value" * Scale;
            if Target."Target Quantity" > 0 then
                MinQuantity := Target."Target Quantity" * Scale;
            OverrideGrowth := Target."Min Growth %";
        end;
        exit((SalesValue >= MinValue) and (Quantity >= MinQuantity));
    end;

    local procedure GetCustomerTarget(SchemeCode: Code[20]; CustomerNo: Code[20]; TierCode: Code[20]; var Target: Record "PTV Scheme Customer Target"): Boolean
    begin
        if Target.Get(SchemeCode, CustomerNo, TierCode) then
            if Target.Active then
                exit(true);
        if TierCode <> '' then
            if Target.Get(SchemeCode, CustomerNo, '') then
                exit(Target.Active);
        exit(false);
    end;

    local procedure ComputeLinePayout(Slab: Record "PTV Scheme Slab"; EligibleQty: Decimal; NetVal: Decimal; var RebateAmt: Decimal; var FOCQty: Decimal)
    var
        ExcessQty: Decimal;
        BuyQuantity: Decimal;
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
                    BuyQuantity := Slab."FOC Buy Quantity";
                    if BuyQuantity = 0 then
                        BuyQuantity := Slab."From Quantity";
                    if Slab."Proportional FOC" and (BuyQuantity > 0) then begin
                        FOCQty := EligibleQty / BuyQuantity;
                        if Slab."FOC Complete Blocks Only" then
                            FOCQty := Round(FOCQty, 1, '<');
                        FOCQty *= Slab."FOC Quantity";
                    end else
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
                        if Slab."Multiple Base Value" > 0 then begin
                            if Multiples < 1 then
                                Multiples := 1;
                            BaseThreshold := Multiples * Slab."Multiple Base Value";
                        end else
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
        Posted: Record "PTV Posted Scheme Entitlement";
    begin
        Entitlement.SetRange("Scheme Code", SchemeCode);
        Entitlement.SetRange("Customer No.", CustomerNo);
        Entitlement.SetRange("Period Start Date", PeriodStart);
        Entitlement.SetRange("Period End Date", PeriodEnd);
        Entitlement.SetRange("Scheme Line No.", LineNo);
        if not Entitlement.IsEmpty() then
            exit(true);
        Posted.SetRange("Scheme Code", SchemeCode);
        Posted.SetRange("Customer No.", CustomerNo);
        Posted.SetRange("Period Start Date", PeriodStart);
        Posted.SetRange("Period End Date", PeriodEnd);
        Posted.SetRange("Scheme Line No.", LineNo);
        exit(not Posted.IsEmpty());
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
