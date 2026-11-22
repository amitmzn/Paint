tableextension 76038 "PTV Production Order" extends "Production Order"
{
    fields
    {
        field(76000; "PTV Batch No."; Code[20])
        {
            Caption = 'Batch No.';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                MfgEvents: Codeunit "PTV Mfg Events";
            begin
                MfgEvents.SyncBatchTracking(Rec);
            end;
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
        field(76300; "PTV Root Demand Forecast"; Code[20])
        {
            Caption = 'Root Demand Forecast';
            DataClassification = CustomerContent;
            TableRelation = "Production Forecast Name".Name;
        }
        field(76301; "PTV Root FG Item No."; Code[20])
        {
            Caption = 'Root FG Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item."No.";
        }
        field(76302; "PTV Parent Source Type"; Enum "PTV Planning Source Type")
        {
            Caption = 'Parent Source Type';
            DataClassification = CustomerContent;
        }
        field(76303; "PTV Parent Source No."; Code[20])
        {
            Caption = 'Parent Source No.';
            DataClassification = CustomerContent;
        }
        field(76304; "PTV Parent Source Line No."; Integer)
        {
            Caption = 'Parent Source Line No.';
            DataClassification = CustomerContent;
        }
        field(76305; "PTV Root FG Prod. Order No."; Code[20])
        {
            Caption = 'Root FG Prod. Order No.';
            DataClassification = CustomerContent;
        }
        field(76306; "PTV Parent Wksh. Template"; Code[10])
        {
            Caption = 'Parent Worksheet Template Name';
            DataClassification = CustomerContent;
        }
        field(76307; "PTV Parent Wksh. Batch Name"; Code[10])
        {
            Caption = 'Parent Worksheet Batch Name';
            DataClassification = CustomerContent;
        }
        field(76309; "PTV Multiple Parents"; Boolean)
        {
            Caption = 'Multiple Parents';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(PTVBatch; "PTV Batch No.")
        {
        }
    }

    /// <summary>
    /// Returns the parent reference, or Multiple (Drill-down) when the order is pegged to more than one parent.
    /// </summary>
    procedure PTVParentSourceCaption(): Text[30]
    begin
        if Rec."PTV Multiple Parents" then
            exit('Multiple (Drill-down)');
        exit(Rec."PTV Parent Source No.");
    end;
}
