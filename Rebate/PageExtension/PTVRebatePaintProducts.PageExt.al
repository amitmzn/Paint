pageextension 77103 "PTV Rebate Paint Products" extends "PTV Paint Products"
{
    layout
    {
        addlast(Lines)
        {
            field("PTV Product Segment"; Rec."PTV Product Segment")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the product segment used for scheme mix reporting (Luxury, Premium, Budget & Economy, etc.).';
            }
            field("PTV Rebate Measure"; Rec."PTV Rebate Measure")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies how quantities are measured in incentive schemes (Auto, Litres, Kilograms).';
            }
        }
    }
}
