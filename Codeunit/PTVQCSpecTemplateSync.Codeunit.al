codeunit 76210 "PTV QC Spec-Template Sync"
{
    /// <summary>
    /// Synchronises the selected certified specifications into standard quality inspection templates.
    /// </summary>
    /// <param name="Spec">Filtered specification rows to synchronise.</param>
    procedure SyncSpecSet(var Spec: Record "PTV QC Paint Spec")
    begin
        Spec.SetRange(Status, Spec.Status::Certified);
        Spec.SetCurrentKey("Item No.", "Shade Code", "Test Code", Version);
        Spec.SetLoadFields("Item No.", "Shade Code", "Test Code", Target, "Min Limit", "Max Limit", Status);
        if Spec.FindSet() then
            repeat
                SyncSpecToTemplate(Spec);
            until Spec.Next() = 0;
    end;

    /// <summary>
    /// Creates or updates one standard template line from a certified specification and assigns the template to the item.
    /// Shade-specific templates take precedence over the item-level template when the item shade matches.
    /// </summary>
    /// <param name="Spec">Certified specification row.</param>
    procedure SyncSpecToTemplate(Spec: Record "PTV QC Paint Spec")
    var
        TemplateHeader: Record "Qlty. Inspection Template Hdr.";
        TemplateCode: Code[20];
    begin
        Spec.TestField(Status, Spec.Status::Certified);
        TemplateCode := GetTemplateCode(Spec."Item No.", Spec."Shade Code");
        if not TemplateHeader.Get(TemplateCode) then begin
            TemplateHeader.Init();
            TemplateHeader.Code := TemplateCode;
            TemplateHeader.Description := CopyStr(StrSubstNo('PTV %1 %2', Spec."Item No.", Spec."Shade Code"), 1, MaxStrLen(TemplateHeader.Description));
            TemplateHeader.Insert(true);
        end;
        UpsertTemplateLine(TemplateHeader.Code, Spec);
        AssignTemplate(Spec."Item No.", Spec."Shade Code", TemplateCode);
    end;

    /// <summary>
    /// Snapshots shade and delta E targets onto an inspection immediately after Quality Management creates it.
    /// Subscribes to Qlty. Inspection - Create.OnAfterCreateInspectionBeforeDialog, which is raised after the header exists and before any dialog.
    /// </summary>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Qlty. Inspection - Create", OnAfterCreateInspectionBeforeDialog, '', false, false)]
    local procedure SnapshotShadeOnCreate(var TargetRecordRef: RecordRef; var TriggeringRecordRef: RecordRef; var IsManualCreation: Boolean; var OptionalSpecificTemplate: Code[20]; var TempQltyInspectionGenRule: Record "Qlty. Inspection Gen. Rule" temporary; var QltyInspectionHeader: Record "Qlty. Inspection Header"; var OptionalRec2Variant: Variant; var OptionalRec3Variant: Variant)
    var
        Item: Record Item;
        Shade: Record "PTV Shade";
        Spec: Record "PTV QC Paint Spec";
    begin
        if QltyInspectionHeader."Source Item No." = '' then
            exit;
        Item.SetLoadFields("PTV Shade Code");
        if not Item.Get(QltyInspectionHeader."Source Item No.") then
            exit;
        QltyInspectionHeader."PTV Shade Code" := Item."PTV Shade Code";
        if Shade.Get(Item."PTV Shade Code") then begin
            QltyInspectionHeader."PTV Delta E Target" := 0;
            QltyInspectionHeader."PTV Delta E Min" := 0;
            QltyInspectionHeader."PTV Delta E Max" := Shade."Delta E Max";
        end;
        Spec.SetRange("Item No.", Item."No.");
        Spec.SetRange("Test Code", 'DE');
        Spec.SetRange(Status, Spec.Status::Certified);
        Spec.SetFilter("Shade Code", '%1|%2', Item."PTV Shade Code", '');
        Spec.SetLoadFields("Shade Code", Target, "Min Limit", "Max Limit");
        if Spec.FindLast() then begin
            QltyInspectionHeader."PTV Delta E Target" := Spec.Target;
            QltyInspectionHeader."PTV Delta E Min" := Spec."Min Limit";
            QltyInspectionHeader."PTV Delta E Max" := Spec."Max Limit";
        end;
        QltyInspectionHeader.Modify(true);
    end;

    local procedure GetTemplateCode(ItemNo: Code[20]; ShadeCode: Code[20]): Code[20]
    var
        RawCode: Text;
    begin
        if ShadeCode = '' then
            RawCode := 'PTV-' + ItemNo
        else
            RawCode := 'PTV-' + ItemNo + '-' + ShadeCode;
        exit(CopyStr(RawCode, 1, 20));
    end;

    local procedure UpsertTemplateLine(TemplateCode: Code[20]; Spec: Record "PTV QC Paint Spec")
    var
        TemplateLine: Record "Qlty. Inspection Template Line";
        ConditionConf: Record "Qlty. I. Result Condit. Conf.";
        ConditionText: Text[500];
    begin
        TemplateLine.SetRange("Template Code", TemplateCode);
        TemplateLine.SetRange("Test Code", Spec."Test Code");
        if not TemplateLine.FindFirst() then begin
            TemplateLine.Init();
            TemplateLine."Template Code" := TemplateCode;
            TemplateLine."Line No." := NextLineNo(TemplateCode);
            TemplateLine.Insert(true);
            TemplateLine.Validate("Test Code", Spec."Test Code");
            TemplateLine.Modify(true);
        end;

        ConditionText := BuildRangeCondition(Spec."Min Limit", Spec."Max Limit");
        if ConditionConf.Get(ConditionConf."Condition Type"::Template, TemplateCode, 0, TemplateLine."Line No.", Spec."Test Code", 'PASS') then begin
            ConditionConf.Condition := ConditionText;
            ConditionConf."Condition Description" := ConditionText;
            ConditionConf.Modify(true);
        end else begin
            ConditionConf.Init();
            ConditionConf."Condition Type" := ConditionConf."Condition Type"::Template;
            ConditionConf."Target Code" := TemplateCode;
            ConditionConf."Target Line No." := TemplateLine."Line No.";
            ConditionConf."Test Code" := Spec."Test Code";
            ConditionConf."Result Code" := 'PASS';
            ConditionConf.Condition := ConditionText;
            ConditionConf."Condition Description" := ConditionText;
            ConditionConf.Insert(true);
        end;
    end;

    local procedure NextLineNo(TemplateCode: Code[20]): Integer
    var
        TemplateLine: Record "Qlty. Inspection Template Line";
    begin
        TemplateLine.SetRange("Template Code", TemplateCode);
        TemplateLine.SetLoadFields("Line No.");
        if TemplateLine.FindLast() then
            exit(TemplateLine."Line No." + 10000);
        exit(10000);
    end;

    local procedure BuildRangeCondition(MinLimit: Decimal; MaxLimit: Decimal): Text[500]
    begin
        if (MinLimit = 0) and (MaxLimit = 0) then
            exit('0');
        if MinLimit = 0 then
            exit(CopyStr('<=' + Format(MaxLimit, 0, 9), 1, 500));
        if MaxLimit = 0 then
            exit(CopyStr('>=' + Format(MinLimit, 0, 9), 1, 500));
        exit(CopyStr(Format(MinLimit, 0, 9) + '..' + Format(MaxLimit, 0, 9), 1, 500));
    end;

    local procedure AssignTemplate(ItemNo: Code[20]; ShadeCode: Code[20]; TemplateCode: Code[20])
    var
        Item: Record Item;
    begin
        Item.SetLoadFields("PTV Shade Code", "PTV QC Template Code");
        if not Item.Get(ItemNo) then
            exit;
        if (ShadeCode <> '') and (Item."PTV Shade Code" <> ShadeCode) then
            exit;
        if Item."PTV QC Template Code" = TemplateCode then
            exit;
        Item."PTV QC Template Code" := TemplateCode;
        Item.Modify(true);
    end;
}
