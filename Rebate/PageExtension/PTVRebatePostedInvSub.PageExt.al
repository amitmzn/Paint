pageextension 77102 "PTV Rebate Posted Inv. Sub" extends "Posted Sales Invoice Subform"
{
    layout
    {
        addlast(Control1)
        {
            field("PTV FOC Item"; Rec."PTV FOC Item")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies whether this posted line was supplied as an FOC item.';
            }
            field("PTV Special Price"; Rec."PTV Special Price")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies whether this posted line used a special price.';
            }
            field("PTV Tie-Up Discount"; Rec."PTV Tie-Up Discount")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies whether this posted line was under a tie-up discount.';
            }
        }
    }
}
