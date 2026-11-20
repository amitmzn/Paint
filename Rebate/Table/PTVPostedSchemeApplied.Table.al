table 77010 "PTV Posted Scheme Applied"
{
    Caption = 'Posted Scheme Applied Entry';
    DataClassification = CustomerContent;

    fields
    {
        field(77000; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
            DataClassification = CustomerContent;
        }
        field(77001; "Posted Ent. Entry No."; Integer)
        {
            Caption = 'Posted Entitlement Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "PTV Posted Scheme Entitlement"."Entry No.";
        }
        field(77002; "Scheme Code"; Code[20])
        {
            Caption = 'Scheme Code';
            DataClassification = CustomerContent;
        }
        field(77003; "Exclusion Group"; Code[20])
        {
            Caption = 'Exclusion Group';
            DataClassification = CustomerContent;
        }
        field(77004; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
        }
        field(77005; "Source Document Type"; Enum "PTV Scheme Applied Doc Type")
        {
            Caption = 'Source Document Type';
            DataClassification = CustomerContent;
        }
        field(77006; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
        field(77007; "Document Line No."; Integer)
        {
            Caption = 'Document Line No.';
            DataClassification = CustomerContent;
        }
        field(77008; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
        }
        field(77009; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
        }
        field(77010; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
        }
        field(77011; "Eligible Qty (Kg/Ltr)"; Decimal)
        {
            Caption = 'Eligible Qty (Kg/Ltr)';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 4;
        }
        field(77012; "Net Amount"; Decimal)
        {
            Caption = 'Net Amount';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(PostedEnt; "Posted Ent. Entry No.")
        {
        }
        key(SourceDocLine; "Source Document Type", "Document No.", "Document Line No.", "Exclusion Group")
        {
        }
    }
}
