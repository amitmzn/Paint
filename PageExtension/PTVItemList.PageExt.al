pageextension 76101 "PTV Item List" extends "Item List"
{
    layout
    {
        addlast(Control1)
        {
            field("PTV Product Code"; Rec."PTV Product Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the paint formula.';
            }
            field("PTV Shade Code"; Rec."PTV Shade Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the shade.';
            }
            field("PTV Pack Code"; Rec."PTV Pack Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the pack.';
            }
            field("PTV Item Role"; Rec."PTV Item Role")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the item role.';
            }
            field("PTV Item Approved"; Rec."PTV Item Approved")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies that the item has been approved.';
            }
        }
    }
}
