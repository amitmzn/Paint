tableextension 76041 "PTV Production BOM Header" extends "Production BOM Header"
{
    fields
    {
        field(76000; "PTV Formula No."; Code[20])
        {
            Caption = 'Formula No.';
            DataClassification = CustomerContent;
            TableRelation = "PTV Paint Product".Code;
        }
        field(76001; "PTV Formula Status"; Enum "PTV Product Status")
        {
            Caption = 'Formula Status';
            DataClassification = CustomerContent;
        }
    }
}
