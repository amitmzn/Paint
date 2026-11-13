page 76065 "PTV Item Approval"
{
    ApplicationArea = All;
    Caption = 'Paint Item Approval';
    PageType = List;
    SourceTable = Item;
    SourceTableView = where(Blocked = const(true), "PTV Item Approved" = const(false));
    UsageCategory = Tasks;
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the item number.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the item description.';
                }
                field("PTV Product Code"; Rec."PTV Product Code")
                {
                    ToolTip = 'Specifies the paint product.';
                }
                field("PTV Shade Code"; Rec."PTV Shade Code")
                {
                    ToolTip = 'Specifies the shade.';
                }
                field("PTV Pack Code"; Rec."PTV Pack Code")
                {
                    ToolTip = 'Specifies the pack.';
                }
                field("PTV Specific Gravity"; Rec."PTV Specific Gravity")
                {
                    ToolTip = 'Specifies the specific gravity.';
                }
                field("PTV Item Role"; Rec."PTV Item Role")
                {
                    ToolTip = 'Specifies the item role.';
                }
                field("PTV Created On"; Rec."PTV Created On")
                {
                    ToolTip = 'Specifies when the item was created.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Approve)
            {
                ApplicationArea = All;
                Caption = 'Approve';
                Image = Approve;
                ToolTip = 'Checks mandatory fields, then unblocks the item and stamps the approver.';

                trigger OnAction()
                var
                    Item: Record Item;
                    ItemApprovalMgt: Codeunit "PTV Item Approval Mgt";
                begin
                    CurrPage.SetSelectionFilter(Item);
                    Item.SetLoadFields("No.");
                    if Item.FindSet() then
                        repeat
                            ItemApprovalMgt.ApproveItem(Item."No.");
                        until Item.Next() = 0;
                end;
            }
        }
    }
}
