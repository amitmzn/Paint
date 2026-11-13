tableextension 76036 "PTV Purchase Header" extends "Purchase Header"
{
    fields
    {
        field(76000; "PTV Voyage No."; Code[20])
        {
            Caption = 'Voyage No.';
            DataClassification = CustomerContent;
        }
        field(76001; "PTV Container No."; Code[20])
        {
            Caption = 'Container No.';
            DataClassification = CustomerContent;
        }
        field(76002; "PTV Port of Loading"; Text[50])
        {
            Caption = 'Port of Loading';
            DataClassification = CustomerContent;
        }
        field(76003; "PTV Port of Discharge"; Text[50])
        {
            Caption = 'Port of Discharge';
            DataClassification = CustomerContent;
        }
    }
}
