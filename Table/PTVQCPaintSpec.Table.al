table 76007 "PTV QC Paint Spec"
{
    Caption = 'QC Paint Spec';
    DataClassification = CustomerContent;
    LookupPageId = "PTV QC Paint Specs";
    DrillDownPageId = "PTV QC Paint Specs";

    fields
    {
        field(76000; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = Item."No.";
        }
        field(76001; "Shade Code"; Code[20])
        {
            Caption = 'Shade Code';
            DataClassification = CustomerContent;
            TableRelation = "PTV Shade".Code;
        }
        field(76002; "Test Code"; Code[20])
        {
            Caption = 'Test Code';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "Qlty. Test".Code;
        }
        field(76003; Version; Integer)
        {
            Caption = 'Version';
            DataClassification = CustomerContent;
            InitValue = 1;
            MinValue = 1;
        }
        field(76004; Target; Decimal)
        {
            Caption = 'Target';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
        field(76005; "Min Limit"; Decimal)
        {
            Caption = 'Min Limit';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
        field(76006; "Max Limit"; Decimal)
        {
            Caption = 'Max Limit';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
        field(76007; "Mandatory Pass"; Boolean)
        {
            Caption = 'Mandatory Pass';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(76008; Status; Enum "PTV QC Spec Status")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Item No.", "Shade Code", "Test Code", Version)
        {
            Clustered = true;
        }
        key(Status; Status, "Item No.", "Shade Code")
        {
        }
    }
}
