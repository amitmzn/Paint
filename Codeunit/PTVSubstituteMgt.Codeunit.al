codeunit 76205 "PTV Substitute Mgt"
{
    [EventSubscriber(ObjectType::Table, Database::"Prod. Order Component", OnAfterValidateEvent, 'Item No.', false, false)]
    local procedure ApplySubstitute(var Rec: Record "Prod. Order Component"; var xRec: Record "Prod. Order Component"; CurrFieldNo: Integer)
    var
        SubstituteItem: Record "PTV Substitute Item";
        SubstituteNotice: Notification;
        AppliedMsg: Label 'Substitute %1 replaced %2 using conversion factor %3.', Comment = '%1 = substitute, %2 = original, %3 = factor';
    begin
        if Rec.IsTemporary then
            exit;
        if Rec."Item No." = xRec."Item No." then
            exit;
        if xRec."Item No." = '' then
            exit;
        SubstituteItem.SetLoadFields("Conversion Factor", Active);
        if not SubstituteItem.Get(xRec."Item No.", Rec."Item No.") then
            exit;
        if not SubstituteItem.Active then
            exit;
        if SubstituteItem."Conversion Factor" = 0 then
            exit;

        Rec."PTV Substitute" := true;
        Rec."PTV Original Item No." := xRec."Item No.";
        Rec."PTV Conversion Factor" := SubstituteItem."Conversion Factor";
        if Rec."Quantity per" <> 0 then
            Rec.Validate("Quantity per", Rec."Quantity per" * SubstituteItem."Conversion Factor");
        SubstituteNotice.Message := StrSubstNo(AppliedMsg, Rec."Item No.", xRec."Item No.", SubstituteItem."Conversion Factor");
        SubstituteNotice.Send();
    end;
}
