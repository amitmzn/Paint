table 77009 "PTV Posted Scheme Entitlement"
{
    Caption = 'Posted Scheme Entitlement';
    DataClassification = CustomerContent;

    fields
    {
        field(77000; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
            DataClassification = CustomerContent;
        }
        field(77001; "Original Entry No."; Integer)
        {
            Caption = 'Original Entry No.';
            DataClassification = CustomerContent;
        }
        field(77002; "Scheme Code"; Code[20])
        {
            Caption = 'Scheme Code';
            DataClassification = CustomerContent;
            TableRelation = "PTV Scheme Header".Code;
        }
        field(77003; "Scheme Line No."; Integer)
        {
            Caption = 'Scheme Line No.';
            DataClassification = CustomerContent;
        }
        field(77004; "Slab No."; Integer)
        {
            Caption = 'Slab No.';
            DataClassification = CustomerContent;
        }
        field(77005; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer."No.";
        }
        field(77006; "Scheme Product Group"; Code[20])
        {
            Caption = 'Scheme Product Group';
            DataClassification = CustomerContent;
        }
        field(77007; "Period Start Date"; Date)
        {
            Caption = 'Period Start Date';
            DataClassification = CustomerContent;
        }
        field(77008; "Period End Date"; Date)
        {
            Caption = 'Period End Date';
            DataClassification = CustomerContent;
        }
        field(77009; "Eligible Qty (Kg/Ltr)"; Decimal)
        {
            Caption = 'Eligible Qty (Kg/Ltr)';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 4;
        }
        field(77010; "Net Sales Value"; Decimal)
        {
            Caption = 'Net Sales Value';
            DataClassification = CustomerContent;
        }
        field(77011; "Prior Year Qty"; Decimal)
        {
            Caption = 'Prior Year Qty';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 4;
        }
        field(77012; "Prior Year Value"; Decimal)
        {
            Caption = 'Prior Year Value';
            DataClassification = CustomerContent;
        }
        field(77013; "Growth %"; Decimal)
        {
            Caption = 'Growth %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
        }
        field(77014; "Discount Type"; Enum "PTV Rebate Discount Type")
        {
            Caption = 'Reward / Discount Type';
            DataClassification = CustomerContent;
        }
        field(77015; "Reward Choice"; Enum "PTV Reward Choice")
        {
            Caption = 'Reward Choice';
            DataClassification = CustomerContent;
        }
        field(77016; "Total Rebate Amount"; Decimal)
        {
            Caption = 'Total Rebate Amount';
            DataClassification = CustomerContent;
        }
        field(77017; "FOC Item No."; Code[20])
        {
            Caption = 'FOC Item No.';
            DataClassification = CustomerContent;
        }
        field(77018; "FOC Quantity"; Decimal)
        {
            Caption = 'FOC Quantity';
            DataClassification = CustomerContent;
        }
        field(77019; "Trip Description"; Text[100])
        {
            Caption = 'Trip Option Description';
            DataClassification = CustomerContent;
        }
        field(77020; "Credit Memo No."; Code[20])
        {
            Caption = 'Credit Memo No.';
            DataClassification = CustomerContent;
        }
        field(77021; "FOC Sales Order No."; Code[20])
        {
            Caption = 'FOC Sales Order No.';
            DataClassification = CustomerContent;
        }
        field(77022; Status; Enum "PTV Entitlement Status")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
        }
        field(77023; "Posted By"; Code[50])
        {
            Caption = 'Posted By';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(77024; "Posted Date"; DateTime)
        {
            Caption = 'Posted Date';
            DataClassification = CustomerContent;
        }
        field(77045; "FOC Reviewed By"; Code[50])
        {
            Caption = 'FOC Reviewed By';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(77046; "FOC Reviewed On"; DateTime)
        {
            Caption = 'FOC Reviewed On';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(77047; "Qualification Tier Code"; Code[20])
        {
            Caption = 'Qualification Tier Code';
            DataClassification = CustomerContent;
        }
        field(77048; "Estimated FOC Cost"; Decimal)
        {
            Caption = 'Estimated FOC Cost (LCY)';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(SchemeCust; "Scheme Code", "Customer No.")
        {
        }
    }
}
