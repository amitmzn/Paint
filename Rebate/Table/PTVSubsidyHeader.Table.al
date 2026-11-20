table 77011 "PTV Subsidy Header"
{
    Caption = 'Subsidy Header';
    DataClassification = CustomerContent;
    LookupPageId = "PTV Subsidy List";
    DrillDownPageId = "PTV Subsidy List";

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
        field(77002; "Period Month"; Integer)
        {
            Caption = 'Period Month';
            DataClassification = CustomerContent;
            MinValue = 1;
            MaxValue = 12;

            trigger OnValidate()
            begin
                UpdatePeriodDates();
            end;
        }
        field(77003; "Period Year"; Integer)
        {
            Caption = 'Period Year';
            DataClassification = CustomerContent;
            MinValue = 2000;
            MaxValue = 2100;

            trigger OnValidate()
            begin
                UpdatePeriodDates();
            end;
        }
        field(77004; "Start Date"; Date)
        {
            Caption = 'Start Date';
            DataClassification = CustomerContent;
        }
        field(77005; "End Date"; Date)
        {
            Caption = 'End Date';
            DataClassification = CustomerContent;
        }
        field(77006; "Territory Filter"; Text[100])
        {
            Caption = 'Territory Filter';
            DataClassification = CustomerContent;
        }
        field(77007; "Location Filter"; Text[100])
        {
            Caption = 'Location Filter';
            DataClassification = CustomerContent;
        }
        field(77008; "Rebate G/L Account"; Code[20])
        {
            Caption = 'Subsidy G/L Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account"."No.";
        }
        field(77009; Status; Enum "PTV Scheme Status")
        {
            Caption = 'Status';
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

    trigger OnDelete()
    var
        SubLine: Record "PTV Subsidy Line";
        ClosedErr: Label 'Closed subsidy %1 cannot be deleted.';
    begin
        if Rec.Status = Rec.Status::Closed then
            Error(ClosedErr, Rec.Code);
        SubLine.SetRange("Subsidy Code", Rec.Code);
        SubLine.DeleteAll();
    end;

    local procedure UpdatePeriodDates()
    begin
        if (Rec."Period Month" >= 1) and (Rec."Period Month" <= 12) and (Rec."Period Year" >= 2000) then begin
            Rec."Start Date" := DMY2Date(1, Rec."Period Month", Rec."Period Year");
            Rec."End Date" := CalcDate('<CM>', Rec."Start Date");
        end;
    end;
}
