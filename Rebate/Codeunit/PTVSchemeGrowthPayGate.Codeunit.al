codeunit 77202 "PTV Scheme Growth & Pay Gate"
{
    /// <summary>
    /// Checks whether a customer satisfies the scheme header applicability filters.
    /// </summary>
    procedure IsCustomerEligible(SchemeHdr: Record "PTV Scheme Header"; Customer: Record Customer): Boolean
    begin
        if (SchemeHdr."Trade Channel Filter" <> SchemeHdr."Trade Channel Filter"::" ") and
           (Customer."PTV Trade Channel" <> SchemeHdr."Trade Channel Filter")
        then
            exit(false);

        if (SchemeHdr."Special Price Handling" = SchemeHdr."Special Price Handling"::"Exclude Customer") and
           Customer."PTV Tie-Up Discount Opted"
        then
            exit(false);

        if not MatchesTextFilter(Customer."Territory Code", SchemeHdr."Territory Filter") then
            exit(false);

        if not MatchesTextFilter(Customer."Customer Price Group", SchemeHdr."Cust. Price Group Filter") then
            exit(false);

        if not MatchesTextFilter(Customer."No.", SchemeHdr."Customer Filter") then
            exit(false);

        exit(true);
    end;

    /// <summary>
    /// Checks whether a customer availed special prices or tie-up discounts during the evaluation period.
    /// </summary>
    procedure HasSpecialPriceOrTieUpInPeriod(CustomerNo: Code[20]; PeriodStart: Date; PeriodEnd: Date): Boolean
    var
        SalesInvLine: Record "Sales Invoice Line";
    begin
        SalesInvLine.SetCurrentKey("Sell-to Customer No.", "Posting Date", Type);
        SalesInvLine.SetRange("Sell-to Customer No.", CustomerNo);
        SalesInvLine.SetRange("Posting Date", PeriodStart, PeriodEnd);
        SalesInvLine.SetRange(Type, SalesInvLine.Type::Item);
        SalesInvLine.SetLoadFields("PTV Special Price", "PTV Tie-Up Discount");
        if SalesInvLine.FindSet() then
            repeat
                if SalesInvLine."PTV Special Price" or SalesInvLine."PTV Tie-Up Discount" then
                    exit(true);
            until SalesInvLine.Next() = 0;
        exit(false);
    end;

    /// <summary>
    /// Evaluates whether an item matches a Scheme Product Group (Include/Exclude members).
    /// </summary>
    procedure MatchesProductGroup(GroupCode: Code[20]; ItemNo: Code[20]; ProductCode: Code[20]; ShadeCode: Code[20]; PackCode: Code[20]; ItemCategoryCode: Code[20]): Boolean
    var
        Member: Record "PTV Scheme Prod. Grp. Member";
        Included: Boolean;
    begin
        if GroupCode = '' then
            exit(true);

        Member.SetRange("Group Code", GroupCode);
        Member.SetRange("Line Type", Member."Line Type"::Exclude);
        if Member.FindSet() then
            repeat
                if MemberMatchesItem(Member, ItemNo, ProductCode, ShadeCode, PackCode, ItemCategoryCode) then
                    exit(false);
            until Member.Next() = 0;

        Member.SetRange("Line Type", Member."Line Type"::Include);
        if not Member.FindSet() then
            exit(false);

        repeat
            if MemberMatchesItem(Member, ItemNo, ProductCode, ShadeCode, PackCode, ItemCategoryCode) then begin
                Included := true;
                break;
            end;
        until Member.Next() = 0;

        exit(Included);
    end;

    local procedure MemberMatchesItem(Member: Record "PTV Scheme Prod. Grp. Member"; ItemNo: Code[20]; ProductCode: Code[20]; ShadeCode: Code[20]; PackCode: Code[20]; ItemCategoryCode: Code[20]): Boolean
    begin
        if (Member."Item No." = '') and (Member."Paint Product Code" = '') and (Member."Item Category Code" = '') and
           (Member."Shade Code" = '') and (Member."Pack Code" = '')
        then
            exit(false);

        if (Member."Item No." <> '') and (Member."Item No." <> ItemNo) then
            exit(false);
        if (Member."Paint Product Code" <> '') and (Member."Paint Product Code" <> ProductCode) then
            exit(false);
        if (Member."Item Category Code" <> '') and (Member."Item Category Code" <> ItemCategoryCode) then
            exit(false);
        if (Member."Shade Code" <> '') and (Member."Shade Code" <> ShadeCode) then
            exit(false);
        if (Member."Pack Code" <> '') and (Member."Pack Code" <> PackCode) then
            exit(false);
        exit(true);
    end;

    /// <summary>
    /// Checks whether a sales line matches a single Scheme Line filter.
    /// </summary>
    procedure MatchesSchemeLine(SchemeLine: Record "PTV Scheme Line"; ItemNo: Code[20]; ProductCode: Code[20]; ShadeCode: Code[20]; PackCode: Code[20]; ItemCategoryCode: Code[20]): Boolean
    begin
        if SchemeLine."Scheme Product Group" <> '' then
            if not MatchesProductGroup(SchemeLine."Scheme Product Group", ItemNo, ProductCode, ShadeCode, PackCode, ItemCategoryCode) then
                exit(false);

        if (SchemeLine."Paint Product Code" <> '') and (SchemeLine."Paint Product Code" <> ProductCode) then
            exit(false);
        if (SchemeLine."Shade Code" <> '') and (SchemeLine."Shade Code" <> ShadeCode) then
            exit(false);
        if (SchemeLine."Pack Code" <> '') and (SchemeLine."Pack Code" <> PackCode) then
            exit(false);
        if (SchemeLine."Item No." <> '') and (SchemeLine."Item No." <> ItemNo) then
            exit(false);
        if (SchemeLine."Item Category Code" <> '') and (SchemeLine."Item Category Code" <> ItemCategoryCode) then
            exit(false);

        exit(true);
    end;

    /// <summary>
    /// Converts a line quantity into Litres, Kilograms, or Base UOM based on scheme/group/product measure settings.
    /// </summary>
    procedure GetMeasuredQuantity(ItemNo: Code[20]; UnitOfMeasureCode: Code[10]; Quantity: Decimal; QuantityBase: Decimal; Measure: Enum "PTV Rebate Measure"; GroupCode: Code[20]; var QtyLitres: Decimal; var QtyKg: Decimal): Decimal
    var
        Item: Record Item;
        PaintProduct: Record "PTV Paint Product";
        ProdGroup: Record "PTV Scheme Product Group";
        UOMMgt: Codeunit "PTV UOM Mgt";
        EffectiveMeasure: Enum "PTV Rebate Measure";
        SG: Decimal;
    begin
        QtyLitres := UOMMgt.LineQuantityToLitres(ItemNo, UnitOfMeasureCode, Quantity);
        SG := UOMMgt.GetSpecificGravity(ItemNo);
        if UnitOfMeasureCode = 'KG' then
            QtyKg := Quantity
        else
            QtyKg := UOMMgt.WeightFromVolume(QtyLitres, SG);

        EffectiveMeasure := Measure;
        if (EffectiveMeasure = EffectiveMeasure::Auto) and (GroupCode <> '') then
            if ProdGroup.Get(GroupCode) and (ProdGroup."Rebate Measure" <> ProdGroup."Rebate Measure"::Auto) then
                EffectiveMeasure := ProdGroup."Rebate Measure";

        if EffectiveMeasure = EffectiveMeasure::Auto then begin
            Item.SetLoadFields("PTV Product Code", "Base Unit of Measure");
            if Item.Get(ItemNo) then begin
                if PaintProduct.Get(Item."PTV Product Code") then begin
                    if PaintProduct."PTV Rebate Measure" <> PaintProduct."PTV Rebate Measure"::Auto then
                        EffectiveMeasure := PaintProduct."PTV Rebate Measure"
                    else
                        if PaintProduct."Base Type" = PaintProduct."Base Type"::Powder then
                            EffectiveMeasure := EffectiveMeasure::Kilograms
                        else
                            EffectiveMeasure := EffectiveMeasure::Litres;
                end else
                    if Item."Base Unit of Measure" = 'KG' then
                        EffectiveMeasure := EffectiveMeasure::Kilograms
                    else
                        EffectiveMeasure := EffectiveMeasure::Litres;
            end;
        end;

        case EffectiveMeasure of
            EffectiveMeasure::Litres:
                exit(QtyLitres);
            EffectiveMeasure::Kilograms:
                begin
                    if QtyKg <> 0 then
                        exit(QtyKg);
                    exit(QuantityBase);
                end;
            EffectiveMeasure::"Base UOM":
                exit(QuantityBase);
            else
                exit(QtyLitres);
        end;
    end;

    /// <summary>
    /// Computes YoY growth percentage. Returns 100 when prior base is 0 and current is positive.
    /// </summary>
    procedure ComputeGrowthPct(CurrentVal: Decimal; PriorVal: Decimal): Decimal
    begin
        if PriorVal > 0 then
            exit(Round(((CurrentVal - PriorVal) / PriorVal) * 100, 0.01));
        if CurrentVal > 0 then
            exit(100);
        exit(0);
    end;

    /// <summary>
    /// Verifies payment clearance on customer ledger entries according to the scheme payment gate mode.
    /// </summary>
    procedure CheckPaymentCleared(SchemeHdr: Record "PTV Scheme Header"; CustomerNo: Code[20]; PeriodStart: Date; PeriodEnd: Date; EntitlementEntryNo: Integer; var UnpaidAmount: Decimal): Boolean
    var
        CustLedgEntry: Record "Cust. Ledger Entry";
        AppliedEntry: Record "PTV Scheme Applied Entry";
        CheckedDocs: Dictionary of [Code[20], Boolean];
    begin
        UnpaidAmount := 0;
        if SchemeHdr."Payment Gate Mode" = SchemeHdr."Payment Gate Mode"::None then
            exit(true);

        if SchemeHdr."Payment Gate Mode" = SchemeHdr."Payment Gate Mode"::"All Period Invoices" then begin
            CustLedgEntry.SetCurrentKey("Customer No.", "Posting Date", Open);
            CustLedgEntry.SetRange("Customer No.", CustomerNo);
            CustLedgEntry.SetRange("Document Type", CustLedgEntry."Document Type"::Invoice);
            CustLedgEntry.SetRange("Posting Date", PeriodStart, PeriodEnd);
            CustLedgEntry.SetRange(Open, true);
            CustLedgEntry.SetLoadFields("Document No.", "Remaining Amount");
            if CustLedgEntry.FindSet() then
                repeat
                    CustLedgEntry.CalcFields("Remaining Amount");
                    if CustLedgEntry."Remaining Amount" > 0 then
                        UnpaidAmount += CustLedgEntry."Remaining Amount";
                until CustLedgEntry.Next() = 0;
            exit(UnpaidAmount <= 0);
        end;

        // Scheme-Eligible Invoices Only
        AppliedEntry.SetRange("Entitlement Entry No.", EntitlementEntryNo);
        AppliedEntry.SetRange("Source Document Type", AppliedEntry."Source Document Type"::"Sales Invoice");
        AppliedEntry.SetLoadFields("Document No.");
        if AppliedEntry.FindSet() then
            repeat
                if not CheckedDocs.ContainsKey(AppliedEntry."Document No.") then begin
                    CheckedDocs.Add(AppliedEntry."Document No.", true);
                    CustLedgEntry.Reset();
                    CustLedgEntry.SetCurrentKey("Document No.");
                    CustLedgEntry.SetRange("Customer No.", CustomerNo);
                    CustLedgEntry.SetRange("Document Type", CustLedgEntry."Document Type"::Invoice);
                    CustLedgEntry.SetRange("Document No.", AppliedEntry."Document No.");
                    CustLedgEntry.SetRange(Open, true);
                    CustLedgEntry.SetLoadFields("Remaining Amount");
                    if CustLedgEntry.FindSet() then
                        repeat
                            CustLedgEntry.CalcFields("Remaining Amount");
                            if CustLedgEntry."Remaining Amount" > 0 then
                                UnpaidAmount += CustLedgEntry."Remaining Amount";
                        until CustLedgEntry.Next() = 0;
                end;
            until AppliedEntry.Next() = 0;

        exit(UnpaidAmount <= 0);
    end;

    /// <summary>
    /// Evaluates a standard BC filter string (e.g. 'KA|GA|KOL') against a single code value.
    /// </summary>
    procedure MatchesTextFilter(ValueCode: Code[20]; FilterText: Text[100]): Boolean
    var
        CustomerFilterTest: Record Customer temporary;
    begin
        if FilterText = '' then
            exit(true);
        if ValueCode = '' then
            exit(false);
        CustomerFilterTest.Init();
        CustomerFilterTest."No." := ValueCode;
        CustomerFilterTest.Insert();
        CustomerFilterTest.SetFilter("No.", FilterText);
        exit(not CustomerFilterTest.IsEmpty());
    end;
}
