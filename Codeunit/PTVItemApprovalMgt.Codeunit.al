codeunit 76204 "PTV Item Approval Mgt"
{
    /// <summary>
    /// Validates mandatory fields, unblocks the item, and stamps the approver.
    /// This is the only procedure that clears Item.Blocked.
    /// </summary>
    /// <param name="ItemNo">Item to approve.</param>
    procedure ApproveItem(ItemNo: Code[20])
    var
        Item: Record Item;
        MasterValidation: Codeunit "PTV Master Validation";
    begin
        Item.Get(ItemNo);
        MasterValidation.CheckItem(Item);
        Item.Blocked := false;
        Item."PTV Item Approved" := true;
        Item."PTV Approved By" := CopyStr(UserId(), 1, MaxStrLen(Item."PTV Approved By"));
        Item."PTV Approved On" := Today;
        Item.Modify(true);
    end;
}
