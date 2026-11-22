tableextension 76320 "PTV Requisition Line" extends "Requisition Line"
{
    fields
    {
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
        field(76308; "PTV Trace Entry Count"; Integer)
        {
            Caption = 'Trace Entry Count';
            FieldClass = FlowField;
            CalcFormula = count("PTV Planning Trace Entry" where("Child Document Type" = const("Planning Worksheet"), "Child Wksh. Template Name" = field("Worksheet Template Name"), "Child Wksh. Batch Name" = field("Journal Batch Name"), "Child Line No." = field("Line No.")));
            Editable = false;
        }
        field(76309; "PTV Multiple Parents"; Boolean)
        {
            Caption = 'Multiple Parents';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    /// <summary>
    /// Returns the parent reference, or Multiple (Drill-down) when the line is pegged to more than one parent.
    /// </summary>
    procedure PTVParentSourceCaption(): Text[30]
    begin
        if Rec."PTV Multiple Parents" then
            exit('Multiple (Drill-down)');
        exit(Rec."PTV Parent Source No.");
    end;
}
