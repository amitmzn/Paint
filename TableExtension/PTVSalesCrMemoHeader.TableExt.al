tableextension 76049 "PTV Sales Cr.Memo Header" extends "Sales Cr.Memo Header"
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
