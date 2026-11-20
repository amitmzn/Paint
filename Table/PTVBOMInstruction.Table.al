table 76006 "PTV BOM Instruction"
{
    Caption = 'BOM Instruction';
    DataClassification = CustomerContent;

    fields
    {
        field(76000; "BOM No."; Code[20])
        {
            Caption = 'BOM No.';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "Production BOM Header"."No.";
        }
        field(76001; "Version Code"; Code[20])
        {
            Caption = 'Version Code';
            DataClassification = CustomerContent;
            TableRelation = "Production BOM Version"."Version Code" where("Production BOM No." = field("BOM No."));
        }
        field(76002; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(76003; "Step No."; Integer)
        {
            Caption = 'Step No.';
            DataClassification = CustomerContent;
        }
        field(76004; Instruction; Text[250])
        {
            Caption = 'Instruction';
            DataClassification = CustomerContent;
        }
        field(76005; "Min Temp C"; Decimal)
        {
            Caption = 'Min. Temperature (°C)';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
        }
        field(76006; "Max Temp C"; Decimal)
        {
            Caption = 'Max. Temperature (°C)';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
        }
        field(76007; "Agitation RPM"; Decimal)
        {
            Caption = 'Agitation RPM';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 0;
            MinValue = 0;
        }
        field(76008; "Duration Min"; Decimal)
        {
            Caption = 'Duration (Min.)';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
            MinValue = 0;
        }
        field(76009; "QC Checkpoint"; Boolean)
        {
            Caption = 'QC Checkpoint';
            DataClassification = CustomerContent;
        }
        field(76010; "Instruction Code"; Code[20])
        {
            Caption = 'Instruction Code';
            DataClassification = CustomerContent;
            TableRelation = "PTV Instruction Master".Code;

            trigger OnValidate()
            var
                InstructionMaster: Record "PTV Instruction Master";
            begin
                if InstructionMaster.Get("Instruction Code") then begin
                    if Instruction = '' then
                        Instruction := InstructionMaster."Standard Instruction Text";
                    if "Min Temp C" = 0 then
                        "Min Temp C" := InstructionMaster."Min Temp C";
                    if "Max Temp C" = 0 then
                        "Max Temp C" := InstructionMaster."Max Temp C";
                    if "Agitation RPM" = 0 then
                        "Agitation RPM" := InstructionMaster."Agitation RPM";
                    if "Duration Min" = 0 then
                        "Duration Min" := InstructionMaster."Duration Min";
                    "QC Checkpoint" := InstructionMaster."QC Checkpoint";
                end;
            end;
        }
    }

    keys
    {
        key(PK; "BOM No.", "Version Code", "Line No.")
        {
            Clustered = true;
        }
        key(Step; "BOM No.", "Version Code", "Step No.")
        {
        }
    }
}
