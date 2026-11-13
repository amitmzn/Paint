table 76005 "PTV Substitute Item"
{
    Caption = 'Substitute Item';
    DataClassification = CustomerContent;
    LookupPageId = "PTV Substitute Items";
    DrillDownPageId = "PTV Substitute Items";

    fields
    {
        field(76000; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = Item."No.";
        }
        field(76001; "Substitute Item No."; Code[20])
        {
            Caption = 'Substitute Item No.';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = Item."No.";
        }
        field(76002; "Conversion Factor"; Decimal)
        {
            Caption = 'Conversion Factor';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            InitValue = 1;
            MinValue = 0;
        }
        field(76003; Active; Boolean)
        {
            Caption = 'Active';
            DataClassification = CustomerContent;
            InitValue = true;
        }
    }

    keys
    {
        key(PK; "Item No.", "Substitute Item No.")
        {
            Clustered = true;
        }
        key(Substitute; "Substitute Item No.", Active)
        {
        }
    }
}
