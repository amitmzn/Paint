pageextension 77101 "PTV Rebate Sales Order Sub" extends "Sales Order Subform"
{
    layout
    {
        addlast(Control1)
        {
            field("PTV FOC Item"; Rec."PTV FOC Item")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies whether this line is a free-of-charge (FOC) scheme item.';
            }
            field("PTV Special Price"; Rec."PTV Special Price")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies whether this line uses a special price excluded from incentive schemes.';
            }
            field("PTV Tie-Up Discount"; Rec."PTV Tie-Up Discount")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies whether this line falls under a tie-up discount.';
            }
        }
    }
}
