page 77066 "PTV Qualification Tiers"
{
    ApplicationArea = All;
    Caption = 'Qualification Tiers';
    PageType = List;
    SourceTable = "PTV Qualification Tier";
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field(Code; Rec.Code)
                {
                    ToolTip = 'Specifies the qualification tier code.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the tier description.';
                }
                field(Sequence; Rec.Sequence)
                {
                    ToolTip = 'Specifies the evaluation sequence.';
                }
                field("Default Min Value"; Rec."Default Min Value")
                {
                    ToolTip = 'Specifies the default minimum sales value.';
                }
                field("Default Min Quantity"; Rec."Default Min Quantity")
                {
                    ToolTip = 'Specifies the default minimum sales quantity.';
                }
                field("Is Base Tier"; Rec."Is Base Tier")
                {
                    ToolTip = 'Specifies whether this is the base tier.';
                }
                field(Active; Rec.Active)
                {
                    ToolTip = 'Specifies whether the tier is active.';
                }
            }
        }
    }
}
