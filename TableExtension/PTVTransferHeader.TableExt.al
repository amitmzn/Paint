tableextension 76044 "PTV Transfer Header" extends "Transfer Header"
{
    fields
    {
        field(76000; "PTV Vehicle No."; Code[20])
        {
            Caption = 'Vehicle No.';
            DataClassification = CustomerContent;
        }
        field(76001; "PTV Vessel Name"; Text[50])
        {
            Caption = 'Vessel Name';
            DataClassification = CustomerContent;
        }
    }
}
