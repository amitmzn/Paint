page 76062 "PTV Shades"
{
    ApplicationArea = All;
    Caption = 'Shades';
    PageType = List;
    SourceTable = "PTV Shade";
    UsageCategory = Lists;
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field(Code; Rec.Code)
                {
                    ToolTip = 'Specifies the shade code.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the shade description.';
                }
                field(Category; Rec.Category)
                {
                    ToolTip = 'Specifies the shade category.';
                }
                field("Lab L Target"; Rec."Lab L Target")
                {
                    ToolTip = 'Specifies the CIELAB L target.';
                }
                field("Lab a Target"; Rec."Lab a Target")
                {
                    ToolTip = 'Specifies the CIELAB a target.';
                }
                field("Lab b Target"; Rec."Lab b Target")
                {
                    ToolTip = 'Specifies the CIELAB b target.';
                }
                field("Delta E Max"; Rec."Delta E Max")
                {
                    ToolTip = 'Specifies the maximum accepted colour difference.';
                }
                field(Blocked; Rec.Blocked)
                {
                    ToolTip = 'Specifies that the shade cannot be assigned to new items.';
                }
            }
        }
    }
}
