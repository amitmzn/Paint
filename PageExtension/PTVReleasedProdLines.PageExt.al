pageextension 76355 "PTV Released Prod. Lines" extends "Released Prod. Order Lines"
{
    layout
    {
        addafter("Item No.")
        {
            field("PTV Root Demand Forecast"; Rec."PTV Root Demand Forecast")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the demand forecast that originated this production order line.';
            }
            field("PTV Parent Source No."; Rec."PTV Parent Source No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the immediate parent order, forecast, or planning line.';
            }
            field("PTV Root FG Prod. Order No."; Rec."PTV Root FG Prod. Order No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the finished-good production order at the root of this chain.';
            }
        }
    }
}
