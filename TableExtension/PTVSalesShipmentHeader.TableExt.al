tableextension 76048 "PTV Sales Shipment Header" extends "Sales Shipment Header"
{
    fields
    {
        field(76000; "PTV Fast Sales"; Boolean)
        {
            Caption = 'Counter Sales';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(76001; "PTV Customer Type"; Enum "PTV Counter Customer Type")
        {
            Caption = 'Customer Type';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(76002; "PTV Mobile No."; Text[30])
        {
            Caption = 'Mobile No.';
            DataClassification = CustomerContent;
            ExtendedDatatype = PhoneNo;
            Editable = false;
        }
    }
}
