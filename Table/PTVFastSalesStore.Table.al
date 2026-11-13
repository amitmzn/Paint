table 76008 "PTV Fast Sales Store"
{
    Caption = 'Fast Sales Store';
    DataClassification = CustomerContent;
    LookupPageId = "PTV Fast Sales Stores";
    DrillDownPageId = "PTV Fast Sales Stores";

    fields
    {
        field(76000; "Location Code"; Code[10])
        {
            Caption = 'Store';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = Location.Code;
        }
        field(76001; "Cash Customer No."; Code[20])
        {
            Caption = 'Cash Customer';
            DataClassification = CustomerContent;
            TableRelation = Customer."No.";
        }
        field(76002; "Responsibility Center"; Code[10])
        {
            Caption = 'Responsibility Centre';
            DataClassification = CustomerContent;
            TableRelation = "Responsibility Center";
        }
        field(76003; "Barcode Scanning"; Boolean)
        {
            Caption = 'Barcode Scanning';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Location Code")
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        UserSetup: Record "User Setup";
        InUseErr: Label 'Store %1 is assigned on User Setup.', Comment = '%1 = store location';
    begin
        UserSetup.SetRange("PTV Store Location Code", "Location Code");
        if not UserSetup.IsEmpty() then
            Error(InUseErr, "Location Code");
    end;
}
