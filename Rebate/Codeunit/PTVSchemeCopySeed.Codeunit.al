codeunit 77205 "PTV Scheme Copy & Seed"
{
    trigger OnRun()
    var
        SeededMsg: Label '2025 PDF scheme templates created/verified (QD-2025-Q1 and BONANZA-2025).';
    begin
        Seed2025PDFSchemes();
        if GuiAllowed() then
            Message(SeededMsg);
    end;

    /// <summary>
    /// Copies a scheme header, lines, and slabs to a new Open scheme.
    /// </summary>
    procedure CopyScheme(SourceCode: Code[20]; NewCode: Code[20])
    var
        SourceHdr: Record "PTV Scheme Header";
        TargetHdr: Record "PTV Scheme Header";
        SourceLine: Record "PTV Scheme Line";
        TargetLine: Record "PTV Scheme Line";
        SourceSlab: Record "PTV Scheme Slab";
        TargetSlab: Record "PTV Scheme Slab";
    begin
        SourceHdr.Get(SourceCode);
        TargetHdr := SourceHdr;
        TargetHdr.Code := NewCode;
        TargetHdr."No. Series" := '';
        TargetHdr.Status := TargetHdr.Status::Open;
        TargetHdr.Insert(true);

        SourceLine.SetRange("Scheme Code", SourceCode);
        if SourceLine.FindSet() then
            repeat
                TargetLine := SourceLine;
                TargetLine."Scheme Code" := TargetHdr.Code;
                TargetLine.Insert(true);
            until SourceLine.Next() = 0;

        SourceSlab.SetRange("Scheme Code", SourceCode);
        if SourceSlab.FindSet() then
            repeat
                TargetSlab := SourceSlab;
                TargetSlab."Scheme Code" := TargetHdr.Code;
                TargetSlab.Insert(true);
            until SourceSlab.Next() = 0;
    end;

    /// <summary>
    /// Idempotently seeds product groups and template configurations for the two 2025 PDF schemes.
    /// </summary>
    procedure Seed2025PDFSchemes()
    var
        RebateSetup: Record "PTV Rebate Setup";
    begin
        RebateSetup.GetSetup();
        SeedSchemeProductGroups();
        SeedQDIncentive2025();
        SeedSummerBonanza2025();
    end;

    local procedure SeedSchemeProductGroups()
    begin
        EnsureGroup('QD-LUXURY', 'LUXURY (Easy Wash Health Shield, Tile Guard, Galaxy, etc.)', Enum::"PTV Product Segment"::Luxury, Enum::"PTV Rebate Measure"::Litres, 10);
        EnsureGroup('QD-PREMIUM', 'PREMIUM (Surfex Premium, Crackfill Paste, PU Floor, etc.)', Enum::"PTV Product Segment"::Premium, Enum::"PTV Rebate Measure"::Auto, 10);
        EnsureGroup('QD-BUDGET', 'BUDGET (Super Shine, Damp Prime, Plastic Emulsion, etc.)', Enum::"PTV Product Segment"::"Budget & Economy", Enum::"PTV Rebate Measure"::Litres, 10);
        EnsureGroup('QD-PRIMERS', 'ALL PRIMERS (Excl. INEX Primer and Damp Prime)', Enum::"PTV Product Segment"::Primers, Enum::"PTV Rebate Measure"::Litres, 10);
        EnsureGroup('QD-DAMPSHIELD', 'Surfa Damp Shield, Damp Shield Extreme', Enum::"PTV Product Segment"::Waterproofing, Enum::"PTV Rebate Measure"::Litres, 10);
        EnsureGroup('QD-WOOD-SPEC', 'Wood Shield, Aluminum Paint, Epoxy Coating, Emerald', Enum::"PTV Product Segment"::"Wood & Industrial", Enum::"PTV Rebate Measure"::Litres, 10);
        EnsureGroup('QD-PUTTY', 'ADR, SAWP & 3D Putty, Champ', Enum::"PTV Product Segment"::"Putty & Powder", Enum::"PTV Rebate Measure"::Kilograms, 10);
        EnsureGroup('QD-LIQ-WP', 'Liquid Water Proof / Surfa Crete SBR, Damp Seal 2K', Enum::"PTV Product Segment"::Waterproofing, Enum::"PTV Rebate Measure"::Auto, 10);
        EnsureGroup('QD-STAINERS', 'Universal Stainers', Enum::"PTV Product Segment"::Stainers, Enum::"PTV Rebate Measure"::Litres, 10);
        EnsureGroup('SB-EXCL-OTHERS', 'Ineligible Products (Others & Crystal Distemper)', Enum::"PTV Product Segment"::Others, Enum::"PTV Rebate Measure"::Auto, 0);
    end;

    local procedure EnsureGroup(GrpCode: Code[20]; GrpDesc: Text[100]; Segment: Enum "PTV Product Segment"; Measure: Enum "PTV Rebate Measure"; MinGrowthPct: Decimal)
    var
        Grp: Record "PTV Scheme Product Group";
    begin
        if Grp.Get(GrpCode) then
            exit;
        Grp.Init();
        Grp.Code := GrpCode;
        Grp.Description := GrpDesc;
        Grp."Product Segment" := Segment;
        Grp."Rebate Measure" := Measure;
        Grp."Default Min Growth %" := MinGrowthPct;
        Grp.Insert(true);
    end;

    local procedure SeedQDIncentive2025()
    var
        Hdr: Record "PTV Scheme Header";
    begin
        if Hdr.Get('QD-2025-Q1') then
            exit;

        Hdr.Init();
        Hdr.Code := 'QD-2025-Q1';
        Hdr.Description := 'Quarterly QD Incentive Scheme - April to June 2025';
        Hdr."Reference No." := '018/OBS/2025-26';
        Hdr."Start Date" := 20250401D;
        Hdr."End Date" := 20250630D;
        Hdr."Scheme Type" := Hdr."Scheme Type"::"Quantity Rate";
        Hdr."Evaluation Period" := Hdr."Evaluation Period"::Monthly;
        Hdr."Calculation Basis" := Hdr."Calculation Basis"::"Auto Kg/Ltr";
        Hdr."Trade Channel Filter" := Hdr."Trade Channel Filter"::Trade;
        Hdr."Exclude FOC Lines" := true;
        Hdr."Special Price Handling" := Hdr."Special Price Handling"::"Exclude Customer";
        Hdr."Require Growth Check" := true;
        Hdr."Default Min Growth %" := 10;
        Hdr."Growth Failure Action" := Hdr."Growth Failure Action"::Disqualify;
        Hdr."Payment Gate Mode" := Hdr."Payment Gate Mode"::"Scheme Invoices";
        Hdr.Status := Hdr.Status::Open;
        Hdr.Insert(true);

        // Groups 1 & 2: 50-100 -> 2, 101-200 -> 3, 201-500 -> 4, 501+ -> 5
        AddQDGroupWith4Slabs('QD-2025-Q1', 10000, 'QD-LUXURY', 50, 100, 2, 101, 200, 3, 201, 500, 4, 501, 0, 5);
        AddQDGroupWith4Slabs('QD-2025-Q1', 20000, 'QD-PREMIUM', 50, 100, 2, 101, 200, 3, 201, 500, 4, 501, 0, 5);
        // Group 3: BUDGET
        AddQDGroupWith4Slabs('QD-2025-Q1', 30000, 'QD-BUDGET', 50, 100, 1.25, 101, 200, 1.50, 201, 500, 2.00, 501, 0, 2.50);
        // Group 4: ALL PRIMERS
        AddQDGroupWith4Slabs('QD-2025-Q1', 40000, 'QD-PRIMERS', 50, 100, 1.00, 101, 200, 1.25, 201, 500, 1.50, 501, 0, 2.00);
        // Group 5: Surfa Damp Shield / Extreme (100-200 -> 20, 201+ -> 25)
        AddQDGroupLine('QD-2025-Q1', 50000, 'QD-DAMPSHIELD');
        AddRateSlab('QD-2025-Q1', 50000, 1, 100, 200, 20);
        AddRateSlab('QD-2025-Q1', 50000, 2, 201, 0, 25);
        // Group 6: Wood Shield / Aluminum / Epoxy / Emerald (30-60 -> 2, 61-100 -> 3, 101+ -> 4)
        AddQDGroupLine('QD-2025-Q1', 60000, 'QD-WOOD-SPEC');
        AddRateSlab('QD-2025-Q1', 60000, 1, 30, 60, 2);
        AddRateSlab('QD-2025-Q1', 60000, 2, 61, 100, 3);
        AddRateSlab('QD-2025-Q1', 60000, 3, 101, 0, 4);
        // Group 7: ADR / SAWP & 3D Putty / Champ (100-200 -> 1, 201-400 -> 1.25, 401+ -> 1.50)
        AddQDGroupLine('QD-2025-Q1', 70000, 'QD-PUTTY');
        AddRateSlab('QD-2025-Q1', 70000, 1, 100, 200, 1.00);
        AddRateSlab('QD-2025-Q1', 70000, 2, 201, 400, 1.25);
        AddRateSlab('QD-2025-Q1', 70000, 3, 401, 0, 1.50);
        // Group 8: Liquid Water Proof / Surfa Crete SBR / Damp Seal 2K (20-40 -> 7, 41-80 -> 12, 81+ -> 17)
        AddQDGroupLine('QD-2025-Q1', 80000, 'QD-LIQ-WP');
        AddRateSlab('QD-2025-Q1', 80000, 1, 20, 40, 7);
        AddRateSlab('QD-2025-Q1', 80000, 2, 41, 80, 12);
        AddRateSlab('QD-2025-Q1', 80000, 3, 81, 0, 17);
        // Group 9: Universal Stainers (20-40 -> 6, 41-80 -> 8, 81+ -> 10)
        AddQDGroupLine('QD-2025-Q1', 90000, 'QD-STAINERS');
        AddRateSlab('QD-2025-Q1', 90000, 1, 20, 40, 6);
        AddRateSlab('QD-2025-Q1', 90000, 2, 41, 80, 8);
        AddRateSlab('QD-2025-Q1', 90000, 3, 81, 0, 10);
    end;

    local procedure SeedSummerBonanza2025()
    var
        Hdr: Record "PTV Scheme Header";
        ExclLine: Record "PTV Scheme Line";
    begin
        if Hdr.Get('BONANZA-2025') then
            exit;

        Hdr.Init();
        Hdr.Code := 'BONANZA-2025';
        Hdr.Description := 'Summer Bonanza Value-Based Scheme - April to June 2025';
        Hdr."Reference No." := '019/OBS/2025-26';
        Hdr."Start Date" := 20250401D;
        Hdr."End Date" := 20250630D;
        Hdr."Scheme Type" := Hdr."Scheme Type"::"Value Rebate";
        Hdr."Evaluation Period" := Hdr."Evaluation Period"::"Full Period";
        Hdr."Calculation Basis" := Hdr."Calculation Basis"::"Net Sales Value";
        Hdr."Trade Channel Filter" := Hdr."Trade Channel Filter"::Trade;
        Hdr."Minimum Net Value" := 100000;
        Hdr."Exclude FOC Lines" := true;
        Hdr."Special Price Handling" := Hdr."Special Price Handling"::"Exclude Line";
        Hdr."Require Growth Check" := true;
        Hdr."Growth Failure Action" := Hdr."Growth Failure Action"::"Step Down";
        Hdr."Payment Gate Mode" := Hdr."Payment Gate Mode"::"All Period Invoices";
        Hdr."Luxury Mix Target %" := 10;
        Hdr."Premium Mix Target %" := 30;
        Hdr."Budget Mix Target %" := 60;
        Hdr.Status := Hdr.Status::Open;
        Hdr.Insert(true);

        // Exclusion line for "Others" & Crystal distemper
        ExclLine.Init();
        ExclLine."Scheme Code" := 'BONANZA-2025';
        ExclLine."Line No." := 10000;
        ExclLine."Line Type" := ExclLine."Line Type"::Exclude;
        ExclLine.Validate("Scheme Product Group", 'SB-EXCL-OTHERS');
        ExclLine.Insert(true);

        // Slabs (line no. = 0 for whole-scheme value rebate)
        AddValuePctSlab('BONANZA-2025', 1, 100000, 200000, 3.5, 25);
        AddValuePctSlab('BONANZA-2025', 2, 200000.01, 400000, 4.0, 15);
        AddValuePctSlab('BONANZA-2025', 3, 400000.01, 600000, 4.5, 13);
        AddValuePctSlab('BONANZA-2025', 4, 600000.01, 800000, 5.0, 11);
        AddTripOrCNSlab('BONANZA-2025', 5, 800000.01, 1300000, 48000, 9, 'Kashi, Prayagraj & Ayodhya (4N 5D)', 0, false, 0, 0);
        AddTripOrCNSlab('BONANZA-2025', 6, 1300000.01, 0, 97500, 7, '1 Ticket to Vietnam/Singapore (4N 5D)', 1300000, true, 100000, 7000);
    end;

    local procedure AddQDGroupWith4Slabs(SchemeCode: Code[20]; LineNo: Integer; GroupCode: Code[20]; Q1F: Decimal; Q1T: Decimal; R1: Decimal; Q2F: Decimal; Q2T: Decimal; R2: Decimal; Q3F: Decimal; Q3T: Decimal; R3: Decimal; Q4F: Decimal; Q4T: Decimal; R4: Decimal)
    begin
        AddQDGroupLine(SchemeCode, LineNo, GroupCode);
        AddRateSlab(SchemeCode, LineNo, 1, Q1F, Q1T, R1);
        AddRateSlab(SchemeCode, LineNo, 2, Q2F, Q2T, R2);
        AddRateSlab(SchemeCode, LineNo, 3, Q3F, Q3T, R3);
        AddRateSlab(SchemeCode, LineNo, 4, Q4F, Q4T, R4);
    end;

    local procedure AddQDGroupLine(SchemeCode: Code[20]; LineNo: Integer; GroupCode: Code[20])
    var
        Line: Record "PTV Scheme Line";
    begin
        Line.Init();
        Line."Scheme Code" := SchemeCode;
        Line."Line No." := LineNo;
        Line."Line Type" := Line."Line Type"::Include;
        Line.Validate("Scheme Product Group", GroupCode);
        Line."Min Growth %" := 10;
        Line.Insert(true);
    end;

    local procedure AddRateSlab(SchemeCode: Code[20]; LineNo: Integer; SlabNo: Integer; FromQty: Decimal; ToQty: Decimal; RatePerUnit: Decimal)
    var
        Slab: Record "PTV Scheme Slab";
    begin
        Slab.Init();
        Slab."Scheme Code" := SchemeCode;
        Slab."Scheme Line No." := LineNo;
        Slab."Slab No." := SlabNo;
        Slab."From Quantity" := FromQty;
        Slab."To Quantity" := ToQty;
        Slab."Min Growth %" := 10;
        Slab."Discount Type" := Slab."Discount Type"::"Rate per Unit";
        Slab."Rate per Unit" := RatePerUnit;
        Slab.Insert(true);
    end;

    local procedure AddValuePctSlab(SchemeCode: Code[20]; SlabNo: Integer; FromVal: Decimal; ToVal: Decimal; Pct: Decimal; MinGrowth: Decimal)
    var
        Slab: Record "PTV Scheme Slab";
    begin
        Slab.Init();
        Slab."Scheme Code" := SchemeCode;
        Slab."Scheme Line No." := 0;
        Slab."Slab No." := SlabNo;
        Slab."From Value" := FromVal;
        Slab."To Value" := ToVal;
        Slab."Min Growth %" := MinGrowth;
        Slab."Discount Type" := Slab."Discount Type"::Percentage;
        Slab."Discount %" := Pct;
        Slab.Insert(true);
    end;

    local procedure AddTripOrCNSlab(SchemeCode: Code[20]; SlabNo: Integer; FromVal: Decimal; ToVal: Decimal; FixedAmt: Decimal; MinGrowth: Decimal; TripDesc: Text[100]; MultiBase: Decimal; AllowMulti: Boolean; IncrStep: Decimal; IncrBonus: Decimal)
    var
        Slab: Record "PTV Scheme Slab";
    begin
        Slab.Init();
        Slab."Scheme Code" := SchemeCode;
        Slab."Scheme Line No." := 0;
        Slab."Slab No." := SlabNo;
        Slab."From Value" := FromVal;
        Slab."To Value" := ToVal;
        Slab."Min Growth %" := MinGrowth;
        Slab."Discount Type" := Slab."Discount Type"::"Trip or Fixed CN";
        Slab."Discount Amount" := FixedAmt;
        Slab."Trip Description" := TripDesc;
        Slab."Multiple Base Value" := MultiBase;
        Slab."Allow Base Multiples" := AllowMulti;
        Slab."Incremental Step Value" := IncrStep;
        Slab."Incremental Bonus Amount" := IncrBonus;
        Slab.Insert(true);
    end;
}
