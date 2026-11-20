pageextension 76116 "PTV Sales Invoice" extends "Sales Invoice"
{
    layout
    {
        addlast(General)
        {
            field("PTV Mobile No."; Rec."PTV Mobile No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the mobile phone number for this invoice.';
            }
        }
    }
}
