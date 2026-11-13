codeunit 76203 "PTV Item Mgt Events"
{
    [EventSubscriber(ObjectType::Table, Database::Item, OnAfterInsertEvent, '', false, false)]
    local procedure BlockNewItems(var Rec: Record Item; RunTrigger: Boolean)
    var
        PaintSetup: Record "PTV Paint Setup";
    begin
        if Rec.IsTemporary then
            exit;
        PaintSetup.GetSetup();
        if not PaintSetup."Block Items On Creation" then
            exit;
        Rec.Blocked := true;
        Rec."PTV Item Approved" := false;
        Rec."PTV Created On" := Today;
        Rec.Modify(false);
    end;
}
