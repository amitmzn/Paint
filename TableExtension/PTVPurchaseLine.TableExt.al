tableextension 76037 "PTV Purchase Line" extends "Purchase Line"
{
    fields
    {
        field(76000; "PTV Product Code"; Code[20])
        {
            Caption = 'Paint Product Code';
            DataClassification = CustomerContent;
            TableRelation = "PTV Paint Product".Code;
        }
        field(76001; "PTV Shade Code"; Code[20])
        {
            Caption = 'Shade Code';
            DataClassification = CustomerContent;
            TableRelation = "PTV Shade".Code;
        }
        field(76002; "PTV Pack Code"; Code[20])
        {
            Caption = 'Pack Code';
            DataClassification = CustomerContent;
            TableRelation = "PTV Pack".Code;
        }
    }
}
