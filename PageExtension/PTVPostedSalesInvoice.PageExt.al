pageextension 76115 "PTV Posted Sales Invoice" extends "Posted Sales Invoice"
{
    layout
    {
        addlast(General)
        {
            field("PTV Customer Type"; Rec."PTV Customer Type")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies whether this was a cash sale or a credit sale.';
            }
            field("PTV Mobile No."; Rec."PTV Mobile No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the customer mobile phone number recorded on the invoice.';
            }
        }
    }
}
