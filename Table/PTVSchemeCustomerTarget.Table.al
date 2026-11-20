table 77006 "PTV Scheme Customer Target"
{
    Caption = 'Scheme Customer Target';
    DataClassification = CustomerContent;

    fields
    {
        field(77000; "Scheme Code"; Code[20])
        {
            Caption = 'Scheme Code';
            DataClassification = CustomerContent;
            TableRelation = "PTV Scheme Header".Code;
        }
        field(77001; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer."No.";

            trigger OnValidate()
            var
                Customer: Record Customer;
            begin
                Customer.SetLoadFields(Name, "Territory Code", "Customer Price Group");
                if Customer.Get(Rec."Customer No.") then begin
                    Rec."Customer Name" := Customer.Name;
                    Rec."Territory Code" := Customer."Territory Code";
                    Rec."Customer Price Group" := Customer."Customer Price Group";
                end;
            end;
        }
        field(77002; "Tier Code"; Code[20])
        {
            Caption = 'Qualification Tier Code';
            DataClassification = CustomerContent;
            TableRelation = "PTV Qualification Tier".Code;
        }
        field(77003; "Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(77004; "Territory Code"; Code[10])
        {
            Caption = 'Territory Code';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(77005; "Customer Price Group"; Code[10])
        {
            Caption = 'Customer Price Group';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(77006; "Target Value"; Decimal)
        {
            Caption = 'Target Value';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(77007; "Target Quantity"; Decimal)
        {
            Caption = 'Target Quantity';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(77008; "Min Growth %"; Decimal)
        {
            Caption = 'Min Growth %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
        }
        field(77009; "Threshold %"; Decimal)
        {
            Caption = 'Threshold %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
            InitValue = 100;
        }
        field(77010; Active; Boolean)
        {
            Caption = 'Active';
            DataClassification = CustomerContent;
            InitValue = true;
        }
    }

    keys
    {
        key(PK; "Scheme Code", "Customer No.", "Tier Code")
        {
            Clustered = true;
        }
    }
}
