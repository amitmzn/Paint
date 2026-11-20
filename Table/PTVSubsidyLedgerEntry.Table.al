table 77013 "PTV Subsidy Ledger Entry"
{
    Caption = 'Subsidy Ledger Entry';
    DataClassification = CustomerContent;

    fields
    {
        field(77000; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
            DataClassification = CustomerContent;
        }
        field(77001; "Subsidy Code"; Code[20])
        {
            Caption = 'Subsidy Code';
            DataClassification = CustomerContent;
        }
        field(77002; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer."No.";
        }
        field(77003; "Subsidy Type"; Enum "PTV Subsidy Type")
        {
            Caption = 'Subsidy Type';
            DataClassification = CustomerContent;
        }
        field(77004; "Beneficiary Name"; Text[100])
        {
            Caption = 'Beneficiary Name';
            DataClassification = CustomerContent;
        }
        field(77005; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
        }
        field(77006; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;
        }
        field(77007; "Credit Memo No."; Code[20])
        {
            Caption = 'Credit Memo No.';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(SubCust; "Subsidy Code", "Customer No.")
        {
        }
    }
}
