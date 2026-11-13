codeunit 76200 "PTV Install & Seed"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        Seed();
    end;

    /// <summary>
    /// Seeds setup, item tracking codes, paint quality tests and the REWORK result. Safe to run more than once.
    /// </summary>
    procedure Seed()
    var
        PaintSetup: Record "PTV Paint Setup";
    begin
        PaintSetup.GetSetup();
        SeedTrackingCodes();
        SeedQualityResults();
        SeedQualityTests();
        SeedMandatoryFields();
    end;

    local procedure SeedTrackingCodes()
    begin
        EnsureTrackingCode('PTVLOT-FG', 'Paint FG lot', true);
        EnsureTrackingCode('PTVLOT-RM', 'Paint RM lot', false);
    end;

    local procedure EnsureTrackingCode(TrackingCode: Code[10]; Description: Text[100]; RequireExpiration: Boolean)
    var
        ItemTrackingCode: Record "Item Tracking Code";
    begin
        if ItemTrackingCode.Get(TrackingCode) then
            exit;
        ItemTrackingCode.Init();
        ItemTrackingCode.Code := TrackingCode;
        ItemTrackingCode.Description := Description;
        ItemTrackingCode."Lot Specific Tracking" := true;
        ItemTrackingCode."Lot Warehouse Tracking" := true;
        ItemTrackingCode."Lot Purchase Inbound Tracking" := true;
        ItemTrackingCode."Lot Purchase Outbound Tracking" := true;
        ItemTrackingCode."Lot Sales Inbound Tracking" := true;
        ItemTrackingCode."Lot Sales Outbound Tracking" := true;
        ItemTrackingCode."Lot Manuf. Inbound Tracking" := true;
        ItemTrackingCode."Lot Manuf. Outbound Tracking" := true;
        ItemTrackingCode."Use Expiration Dates" := RequireExpiration;
        ItemTrackingCode."Man. Expir. Date Entry Reqd." := RequireExpiration;
        ItemTrackingCode."Strict Expiration Posting" := RequireExpiration;
        ItemTrackingCode.Insert(true);
    end;

    local procedure SeedQualityResults()
    begin
        EnsureResult('PASS', 'Pass', Enum::"Qlty. Result Category"::Acceptable, 10);
        EnsureResult('FAIL', 'Fail', Enum::"Qlty. Result Category"::"Not acceptable", 30);
        EnsureResult('REWORK', 'Rework', Enum::"Qlty. Result Category"::"Not acceptable", 20);
    end;

    local procedure EnsureResult(ResultCode: Code[20]; Description: Text[100]; Category: Enum "Qlty. Result Category"; EvaluationSequence: Integer)
    var
        QltyInspectionResult: Record "Qlty. Inspection Result";
    begin
        if QltyInspectionResult.Get(ResultCode) then
            exit;
        QltyInspectionResult.Init();
        QltyInspectionResult.Code := ResultCode;
        QltyInspectionResult.Description := Description;
        QltyInspectionResult."Result Category" := Category;
        QltyInspectionResult."Finish Allowed" := QltyInspectionResult."Finish Allowed"::"Allow Finish";
        QltyInspectionResult."Evaluation Sequence" := EvaluationSequence;
        QltyInspectionResult.Insert(true);
    end;

    local procedure SeedQualityTests()
    begin
        EnsureTest('SG', 'Density/Specific Gravity', 'G/ML');
        EnsureTest('KU', 'Stormer Viscosity', 'KU');
        EnsureTest('FORDCUP', 'Ford Cup', 'SEC');
        EnsureTest('PH', 'pH', 'PH');
        EnsureTest('GRIND', 'Hegman/Fineness of Grind', 'UM');
        EnsureTest('DE', 'Colour Delta E', 'DE');
        EnsureTest('OPACITY', 'Contrast Ratio', 'PCT');
        EnsureTest('GLOSS60', 'Gloss 60', 'GU');
        EnsureTest('DRYTIME', 'Drying Time', 'MIN');
        EnsureTest('TINTSTR', 'Tinting Strength', 'PCT');
        EnsureTest('SOLIDSW', 'Solids by Weight', 'PCT');
        EnsureTest('VOC', 'VOC', 'G/L');
    end;

    local procedure EnsureTest(TestCode: Code[20]; Description: Text[100]; UomCode: Code[10])
    var
        QltyTest: Record "Qlty. Test";
        UnitOfMeasure: Record "Unit of Measure";
    begin
        if not UnitOfMeasure.Get(UomCode) then begin
            UnitOfMeasure.Init();
            UnitOfMeasure.Code := UomCode;
            UnitOfMeasure.Description := UomCode;
            UnitOfMeasure.Insert(true);
        end;
        if QltyTest.Get(TestCode) then
            exit;
        QltyTest.Init();
        QltyTest.Code := TestCode;
        QltyTest.Description := Description;
        QltyTest."Test Value Type" := QltyTest."Test Value Type"::"Value Type Decimal";
        QltyTest."Unit of Measure Code" := UomCode;
        QltyTest.Insert(true);
    end;

    local procedure SeedMandatoryFields()
    begin
        EnsureMandatoryField(Database::Item, 76000, Enum::"PTV Item Role"::"FG Paint");
        EnsureMandatoryField(Database::Item, 76001, Enum::"PTV Item Role"::"FG Paint");
        EnsureMandatoryField(Database::Item, 76002, Enum::"PTV Item Role"::"FG Paint");
        EnsureMandatoryField(Database::Item, 76003, Enum::"PTV Item Role"::"FG Paint");
    end;

    local procedure EnsureMandatoryField(TableNo: Integer; FieldNo: Integer; ItemRole: Enum "PTV Item Role")
    var
        MandatoryFieldSetup: Record "PTV Mandatory Field Setup";
    begin
        if MandatoryFieldSetup.Get(TableNo, FieldNo, ItemRole) then
            exit;
        MandatoryFieldSetup.Init();
        MandatoryFieldSetup."Table No." := TableNo;
        MandatoryFieldSetup."Field No." := FieldNo;
        MandatoryFieldSetup."Item Role" := ItemRole;
        MandatoryFieldSetup.Active := true;
        MandatoryFieldSetup.Insert(true);
    end;
}
