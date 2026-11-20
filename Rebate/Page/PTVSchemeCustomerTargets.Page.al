page 77067 "PTV Scheme Customer Targets"
{
    ApplicationArea = All;
    Caption = 'Scheme Customer Targets';
    PageType = List;
    SourceTable = "PTV Scheme Customer Target";
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Scheme Code"; Rec."Scheme Code")
                {
                    ToolTip = 'Specifies the scheme code.';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ToolTip = 'Specifies the customer number.';
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ToolTip = 'Specifies the customer name.';
                }
                field("Tier Code"; Rec."Tier Code")
                {
                    ToolTip = 'Specifies the qualification tier.';
                }
                field("Target Value"; Rec."Target Value")
                {
                    ToolTip = 'Specifies the customer target value.';
                }
                field("Target Quantity"; Rec."Target Quantity")
                {
                    ToolTip = 'Specifies the customer target quantity.';
                }
                field("Min Growth %"; Rec."Min Growth %")
                {
                    ToolTip = 'Specifies the customer minimum growth percentage.';
                }
                field("Threshold %"; Rec."Threshold %")
                {
                    ToolTip = 'Specifies the achievement threshold percentage.';
                }
                field(Active; Rec.Active)
                {
                    ToolTip = 'Specifies whether this target is active.';
                }
            }
        }
    }
}
