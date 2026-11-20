table 77005 "PTV Qualification Tier"
{
    Caption = 'Qualification Tier';
    DataClassification = CustomerContent;
    LookupPageId = "PTV Qualification Tiers";
    DrillDownPageId = "PTV Qualification Tiers";

    fields
    {
        field(77000; Code; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(77001; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(77002; Sequence; Integer)
        {
            Caption = 'Sequence';
            DataClassification = CustomerContent;
            InitValue = 1;
        }
        field(77003; "Default Min Value"; Decimal)
        {
            Caption = 'Default Min Value';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(77004; "Default Min Quantity"; Decimal)
        {
            Caption = 'Default Min Quantity';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(77005; "Is Base Tier"; Boolean)
        {
            Caption = 'Is Base Tier';
            DataClassification = CustomerContent;
        }
        field(77006; Active; Boolean)
        {
            Caption = 'Active';
            DataClassification = CustomerContent;
            InitValue = true;
        }
    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
        key(Seq; Sequence)
        {
        }
    }
}
