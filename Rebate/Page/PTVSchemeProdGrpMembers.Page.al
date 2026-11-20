page 77073 "PTV Scheme Prod. Grp. Members"
{
    ApplicationArea = All;
    Caption = 'Scheme Product Group Members';
    PageType = ListPart;
    SourceTable = "PTV Scheme Prod. Grp. Member";
    AutoSplitKey = true;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Line Type"; Rec."Line Type")
                {
                    ToolTip = 'Specifies whether matching items are included or excluded.';
                }
                field("Paint Product Code"; Rec."Paint Product Code")
                {
                    ToolTip = 'Specifies the paint product code filter.';
                }
                field("Item Category Code"; Rec."Item Category Code")
                {
                    ToolTip = 'Specifies the item category filter.';
                }
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies a specific item number filter.';
                }
                field("Shade Code"; Rec."Shade Code")
                {
                    ToolTip = 'Specifies a shade filter.';
                }
                field("Pack Code"; Rec."Pack Code")
                {
                    ToolTip = 'Specifies a pack filter.';
                }
            }
        }
    }
}
