table 76002 "PTV Shade"
{
    Caption = 'Shade';
    DataClassification = CustomerContent;
    LookupPageId = "PTV Shades";
    DrillDownPageId = "PTV Shades";

    fields
    {
        field(76000; Code; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(76001; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(76002; Category; Enum "PTV Shade Category")
        {
            Caption = 'Category';
            DataClassification = CustomerContent;
        }
        field(76003; "Lab L Target"; Decimal)
        {
            Caption = 'Lab L Target';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
        }
        field(76004; "Lab a Target"; Decimal)
        {
            Caption = 'Lab a Target';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
        }
        field(76005; "Lab b Target"; Decimal)
        {
            Caption = 'Lab b Target';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
        }
        field(76006; "Delta E Max"; Decimal)
        {
            Caption = 'Delta E Max';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
            InitValue = 1;
            MinValue = 0;
        }
        field(76007; Blocked; Boolean)
        {
            Caption = 'Blocked';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }
}
