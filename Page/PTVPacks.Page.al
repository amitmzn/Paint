page 76063 "PTV Packs"
{
    ApplicationArea = All;
    Caption = 'Packs';
    PageType = List;
    SourceTable = "PTV Pack";
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
                    ToolTip = 'Specifies the pack code.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the pack description.';
                }
                field("Pack Size Litres"; Rec."Pack Size Litres")
                {
                    ToolTip = 'Specifies the container size in litres. This becomes the container unit of measure quantity per.';
                }
                field("Container Type"; Rec."Container Type")
                {
                    ToolTip = 'Specifies the container type.';
                }
                field("Container UOM Code"; Rec."Container UOM Code")
                {
                    ToolTip = 'Specifies the unit of measure that represents one container.';
                }
                field(Blocked; Rec.Blocked)
                {
                    ToolTip = 'Specifies that the pack cannot be assigned to new items.';
                }
            }
        }
    }
}
