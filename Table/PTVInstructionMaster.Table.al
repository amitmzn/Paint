table 76010 "PTV Instruction Master"
{
    Caption = 'Instruction Master';
    DataClassification = CustomerContent;
    LookupPageId = "PTV Instruction Master";
    DrillDownPageId = "PTV Instruction Master";

    fields
    {
        field(76000; "Code"; Code[20])
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
        field(76002; "Standard Instruction Text"; Text[250])
        {
            Caption = 'Standard Instruction Text';
            DataClassification = CustomerContent;
        }
        field(76003; "Min Temp C"; Decimal)
        {
            Caption = 'Min. Temperature (°C)';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
        }
        field(76004; "Max Temp C"; Decimal)
        {
            Caption = 'Max. Temperature (°C)';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
        }
        field(76005; "Agitation RPM"; Decimal)
        {
            Caption = 'Agitation RPM';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 0;
            MinValue = 0;
        }
        field(76006; "Duration Min"; Decimal)
        {
            Caption = 'Duration (Min.)';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
            MinValue = 0;
        }
        field(76007; "QC Checkpoint"; Boolean)
        {
            Caption = 'QC Checkpoint';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }
}
