tableextension 76031 "PTV Sales Header" extends "Sales Header"
{
    fields
    {
        field(76000; "PTV Promised Delivery Date"; Date)
        {
            Caption = 'Promised Delivery Date';
            DataClassification = CustomerContent;
        }
        field(76001; "PTV Dispatch Info"; Text[100])
        {
            Caption = 'Dispatch Info';
            DataClassification = CustomerContent;
        }
        field(76002; "PTV Fast Sales"; Boolean)
        {
            Caption = 'Fast Sales';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }
}
