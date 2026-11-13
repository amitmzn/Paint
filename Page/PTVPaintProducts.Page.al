page 76061 "PTV Paint Products"
{
    ApplicationArea = All;
    Caption = 'Paint Products';
    PageType = List;
    SourceTable = "PTV Paint Product";
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
                    ToolTip = 'Specifies the formula code.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the formula description.';
                }
                field("Paint Type"; Rec."Paint Type")
                {
                    ToolTip = 'Specifies the paint type.';
                }
                field("Base Type"; Rec."Base Type")
                {
                    ToolTip = 'Specifies the base type.';
                }
                field("Specific Gravity"; Rec."Specific Gravity")
                {
                    ToolTip = 'Specifies the default specific gravity for this formula.';
                }
                field(Status; Rec.Status)
                {
                    ToolTip = 'Specifies whether the formula is active.';
                }
                field(Blocked; Rec.Blocked)
                {
                    ToolTip = 'Specifies that the formula cannot be assigned to new items.';
                }
            }
        }
    }
}
