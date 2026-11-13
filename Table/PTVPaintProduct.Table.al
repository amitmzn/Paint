table 76001 "PTV Paint Product"
{
    Caption = 'Paint Product';
    DataClassification = CustomerContent;
    LookupPageId = "PTV Paint Products";
    DrillDownPageId = "PTV Paint Products";

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
        field(76002; "Paint Type"; Enum "PTV Paint Type")
        {
            Caption = 'Paint Type';
            DataClassification = CustomerContent;
        }
        field(76003; "Base Type"; Enum "PTV Base Type")
        {
            Caption = 'Base Type';
            DataClassification = CustomerContent;
        }
        field(76004; Status; Enum "PTV Product Status")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
        }
        field(76005; Blocked; Boolean)
        {
            Caption = 'Blocked';
            DataClassification = CustomerContent;
        }
        field(76006; "Specific Gravity"; Decimal)
        {
            Caption = 'Specific Gravity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 4;
            MinValue = 0;
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
