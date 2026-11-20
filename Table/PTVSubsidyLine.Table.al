table 77012 "PTV Subsidy Line"
{
    Caption = 'Subsidy Line';
    DataClassification = CustomerContent;

    fields
    {
        field(77000; "Subsidy Code"; Code[20])
        {
            Caption = 'Subsidy Code';
            DataClassification = CustomerContent;
            TableRelation = "PTV Subsidy Header".Code;
        }
        field(77001; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(77002; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer."No.";

            trigger OnValidate()
            var
                Customer: Record Customer;
            begin
                Customer.SetLoadFields(Name);
                if Customer.Get(Rec."Customer No.") then
                    Rec."Customer Name" := Customer.Name;
            end;
        }
        field(77003; "Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(77004; "Subsidy Type"; Enum "PTV Subsidy Type")
        {
            Caption = 'Subsidy Type';
            DataClassification = CustomerContent;
        }
        field(77005; "Subsidy Amount"; Decimal)
        {
            Caption = 'Subsidy Amount';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(77006; "Condition Type"; Enum "PTV Subsidy Condition Type")
        {
            Caption = 'Condition Type';
            DataClassification = CustomerContent;
        }
        field(77007; "Minimum Value"; Decimal)
        {
            Caption = 'Minimum Value / Litres';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(77008; "Beneficiary Name"; Text[100])
        {
            Caption = 'Beneficiary Name';
            DataClassification = CustomerContent;
        }
        field(77009; "Actual Sales Value"; Decimal)
        {
            Caption = 'Actual Sales Value';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(77010; "Actual Sales Qty (Kg/Ltr)"; Decimal)
        {
            Caption = 'Actual Sales Qty (Litres)';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(77011; "Sales Qualified"; Boolean)
        {
            Caption = 'Sales Qualified';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(77012; "Entitled Amount"; Decimal)
        {
            Caption = 'Entitled Amount';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(77013; Status; Enum "PTV Entitlement Status")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
        }
        field(77014; "Credit Memo No."; Code[20])
        {
            Caption = 'Credit Memo No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Subsidy Code", "Line No.")
        {
            Clustered = true;
        }
    }
}
