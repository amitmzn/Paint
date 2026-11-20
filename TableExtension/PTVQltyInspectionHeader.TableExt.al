tableextension 76043 "PTV Qlty. Inspection Header" extends "Qlty. Inspection Header"
{
    fields
    {
        field(76000; "PTV Shade Code"; Code[20])
        {
            Caption = 'Shade Code';
            DataClassification = CustomerContent;
            TableRelation = "PTV Shade".Code;
        }
        field(76001; "PTV Delta E Target"; Decimal)
        {
            Caption = 'Delta E Target';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
            Editable = false;
        }
        field(76002; "PTV Delta E Min"; Decimal)
        {
            Caption = 'Delta E Min';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
            Editable = false;
        }
        field(76003; "PTV Delta E Max"; Decimal)
        {
            Caption = 'Delta E Max';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
            Editable = false;
        }
        field(76004; "PTV Specific Gravity"; Decimal)
        {
            Caption = 'Specific Gravity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 4;
            Editable = false;
        }
        field(76005; "PTV VOC g/L"; Decimal)
        {
            Caption = 'VOC (g/L)';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
            Editable = false;
        }
        field(76006; "PTV Solids By Weight %"; Decimal)
        {
            Caption = 'Solids By Weight %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
            Editable = false;
        }
        field(76007; "PTV Lab L Target"; Decimal)
        {
            Caption = 'Lab L Target';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
            Editable = false;
        }
        field(76008; "PTV Lab a Target"; Decimal)
        {
            Caption = 'Lab a Target';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
            Editable = false;
        }
        field(76009; "PTV Lab b Target"; Decimal)
        {
            Caption = 'Lab b Target';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
            Editable = false;
        }
    }
}
