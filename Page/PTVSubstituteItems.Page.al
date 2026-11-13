page 76066 "PTV Substitute Items"
{
    ApplicationArea = All;
    Caption = 'Substitute Items';
    PageType = List;
    SourceTable = "PTV Substitute Item";
    UsageCategory = Lists;
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies the component that may be replaced.';
                }
                field("Substitute Item No."; Rec."Substitute Item No.")
                {
                    ToolTip = 'Specifies the approved substitute item.';
                }
                field("Conversion Factor"; Rec."Conversion Factor")
                {
                    ToolTip = 'Specifies the quantity factor applied when the substitute is used.';
                }
                field(Active; Rec.Active)
                {
                    ToolTip = 'Specifies that the substitution is allowed.';
                }
            }
        }
    }
}
