codeunit 76201 "PTV Master Validation"
{
    /// <summary>
    /// Checks mandatory fields configured for the item role.
    /// </summary>
    /// <param name="Item">Item to validate.</param>
    procedure CheckItem(Item: Record Item)
    var
        PaintSetup: Record "PTV Paint Setup";
        MandatoryFieldSetup: Record "PTV Mandatory Field Setup";
        RecRef: RecordRef;
        FieldRef: FieldRef;
        MissingErr: Label 'Field %1 is mandatory before this item can be approved.', Comment = '%1 = field caption';
    begin
        PaintSetup.GetSetup();
        if not PaintSetup."Mandatory Fields" then
            exit;

        MandatoryFieldSetup.SetRange("Table No.", Database::Item);
        MandatoryFieldSetup.SetRange(Active, true);
        MandatoryFieldSetup.SetFilter("Item Role", '%1|%2', Item."PTV Item Role", MandatoryFieldSetup."Item Role"::" ");
        MandatoryFieldSetup.SetLoadFields("Field No.");
        if not MandatoryFieldSetup.FindSet() then
            exit;

        RecRef.GetTable(Item);
        repeat
            if RecRef.FieldExist(MandatoryFieldSetup."Field No.") then begin
                FieldRef := RecRef.Field(MandatoryFieldSetup."Field No.");
                if IsBlank(FieldRef) then
                    Error(ErrorInfo.Create(StrSubstNo(MissingErr, FieldRef.Caption)));
            end;
        until MandatoryFieldSetup.Next() = 0;
    end;

    local procedure IsBlank(FieldRef: FieldRef): Boolean
    var
        Value: Text;
    begin
        Value := Format(FieldRef.Value);
        exit(DelChr(Value, '=', ' ') = '');
    end;
}
