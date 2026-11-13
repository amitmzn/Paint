table 76003 "PTV Pack"
{
    Caption = 'Pack';
    DataClassification = CustomerContent;
    LookupPageId = "PTV Packs";
    DrillDownPageId = "PTV Packs";

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
        field(76002; "Pack Size Litres"; Decimal)
        {
            Caption = 'Pack Size Litres';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            MinValue = 0;

            trigger OnValidate()
            var
                SizeErr: Label 'Pack size in litres must be greater than zero.';
            begin
                if "Pack Size Litres" <= 0 then
                    Error(SizeErr);
            end;
        }
        field(76003; "Container Type"; Enum "PTV Container Type")
        {
            Caption = 'Container Type';
            DataClassification = CustomerContent;
        }
        field(76004; "Container UOM Code"; Code[10])
        {
            Caption = 'Container UOM Code';
            DataClassification = CustomerContent;
            TableRelation = "Unit of Measure".Code;
        }
        field(76005; Blocked; Boolean)
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
