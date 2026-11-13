pageextension 76104 "PTV Posted Sales Inv. Subform" extends "Posted Sales Invoice Subform"
{
    layout
    {
        addlast(Control1)
        {
            field("PTV Product Code"; Rec."PTV Product Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the paint product posted with this line.';
            }
            field("PTV Shade Code"; Rec."PTV Shade Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the shade posted with this line.';
            }
            field("PTV Pack Code"; Rec."PTV Pack Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the pack posted with this line.';
            }
        }
    }
}
