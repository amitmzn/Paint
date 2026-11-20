tableextension 77035 "PTV Rebate Sales Header" extends "Sales Header"
{
    fields
    {
        field(77000; "PTV Scheme Entitlement Entry"; Integer)
        {
            Caption = 'Scheme Entitlement Entry';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }
}
