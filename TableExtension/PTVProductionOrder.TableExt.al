tableextension 76038 "PTV Production Order" extends "Production Order"
{
    fields
    {
        field(76000; "PTV Batch No."; Code[20])
        {
            Caption = 'Batch No.';
            DataClassification = CustomerContent;
        }
        field(76001; "PTV Formula No."; Code[20])
        {
            Caption = 'Formula No.';
            DataClassification = CustomerContent;
            TableRelation = "PTV Paint Product".Code;
        }
        field(76002; "PTV Shade Code"; Code[20])
        {
            Caption = 'Shade Code';
            DataClassification = CustomerContent;
            TableRelation = "PTV Shade".Code;
        }
        field(76003; "PTV Specific Gravity"; Decimal)
        {
            Caption = 'Specific Gravity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 4;
            Editable = false;
        }
        field(76004; "PTV Rework Order"; Boolean)
        {
            Caption = 'Rework Order';
            DataClassification = CustomerContent;
        }
        field(76005; "PTV Original Batch No."; Code[20])
        {
            Caption = 'Original Batch No.';
            DataClassification = CustomerContent;
        }
        field(76006; "PTV Latest Insp. Result"; Code[20])
        {
            Caption = 'Latest Inspection Result';
            FieldClass = FlowField;
            CalcFormula = lookup("Qlty. Inspection Header"."Result Code" where("Source Item No." = field("Source No."), "Source Lot No." = field("PTV Batch No.")));
            Editable = false;
        }
    }

    keys
    {
        key(PTVBatch; "PTV Batch No.")
        {
        }
    }
}
