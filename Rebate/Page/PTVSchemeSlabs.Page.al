page 77065 "PTV Scheme Slabs"
{
    ApplicationArea = All;
    Caption = 'Scheme Slabs';
    PageType = List;
    SourceTable = "PTV Scheme Slab";
    AutoSplitKey = true;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Slab No."; Rec."Slab No.")
                {
                    ToolTip = 'Specifies the slab sequence number.';
                }
                field("From Quantity"; Rec."From Quantity")
                {
                    ToolTip = 'Specifies the lower quantity bound.';
                }
                field("To Quantity"; Rec."To Quantity")
                {
                    ToolTip = 'Specifies the upper quantity bound (0 = unlimited).';
                }
                field("From Value"; Rec."From Value")
                {
                    ToolTip = 'Specifies the lower sales value bound.';
                }
                field("To Value"; Rec."To Value")
                {
                    ToolTip = 'Specifies the upper sales value bound (0 = unlimited).';
                }
                field("Min Growth %"; Rec."Min Growth %")
                {
                    ToolTip = 'Specifies the minimum YoY growth percentage required for this slab.';
                }
                field("Discount Type"; Rec."Discount Type")
                {
                    ToolTip = 'Specifies how the reward is calculated.';
                }
                field("Rate per Unit"; Rec."Rate per Unit")
                {
                    ToolTip = 'Specifies the Rs. per Kg/Ltr rate.';
                }
                field("Discount %"; Rec."Discount %")
                {
                    ToolTip = 'Specifies the rebate percentage on the scheme sales value.';
                }
                field("Discount Amount"; Rec."Discount Amount")
                {
                    ToolTip = 'Specifies the fixed credit note amount.';
                }
                field("Trip Description"; Rec."Trip Description")
                {
                    ToolTip = 'Specifies the trip / non-monetary reward option.';
                }
                field("Multiple Base Value"; Rec."Multiple Base Value")
                {
                    ToolTip = 'Specifies the base threshold for multiple / incremental bonus calculation.';
                }
                field("Allow Base Multiples"; Rec."Allow Base Multiples")
                {
                    ToolTip = 'Award fixed credit note amount in multiples of Multiple Base Value.';
                }
                field("Incremental Step Value"; Rec."Incremental Step Value")
                {
                    ToolTip = 'Specifies each incremental sales value step above the base threshold.';
                }
                field("Incremental Bonus Amount"; Rec."Incremental Bonus Amount")
                {
                    ToolTip = 'Specifies the extra credit note bonus earned per incremental step.';
                }
                field("FOC Item No."; Rec."FOC Item No.")
                {
                    ToolTip = 'Specifies the FOC item.';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ToolTip = 'Specifies the customer no..';
                }
                field("Qualification Tier Code"; Rec."Qualification Tier Code")
                {
                    ToolTip = 'Specifies the qualification tier code.';
                }
                field("FOC Unit of Measure"; Rec."FOC Unit of Measure")
                {
                    ToolTip = 'Specifies the foc unit of measure.';
                }
                field("Proportional FOC"; Rec."Proportional FOC")
                {
                    ToolTip = 'Specifies the proportional foc.';
                }
                field("FOC Buy Quantity"; Rec."FOC Buy Quantity")
                {
                    ToolTip = 'Specifies the foc buy quantity.';
                }
                field("FOC Complete Blocks Only"; Rec."FOC Complete Blocks Only")
                {
                    ToolTip = 'Specifies the foc complete blocks only.';
                }
                field("Incremental Qty"; Rec."Incremental Qty")
                {
                    ToolTip = 'Specifies the incremental qty.';
                }
                field("Incremental FOC Qty"; Rec."Incremental FOC Qty")
                {
                    ToolTip = 'Specifies the incremental foc qty.';
                }
                field("FOC Quantity"; Rec."FOC Quantity")
                {
                    ToolTip = 'Specifies the FOC quantity.';
                }
            }
        }
    }
}
