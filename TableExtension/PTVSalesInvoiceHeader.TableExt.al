tableextension 76046 "PTV Sales Invoice Header" extends "Sales Invoice Header"
{
    fields
    {
        field(76000; "PTV Fast Sales"; Boolean)
        {
            Caption = 'Fast Sales';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }
}
