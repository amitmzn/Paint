pageextension 76110 "PTV User Setup" extends "User Setup"
{
    layout
    {
        addlast(Control1)
        {
            field("PTV Store Location Code"; Rec."PTV Store Location Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the store for this user. Fast Sales Invoice selects the cash customer for this store.';
            }
        }
    }
}
