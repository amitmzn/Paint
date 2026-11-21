/// <summary>
/// Temporary rows for the multi-level traceability tree. The table is not posted to.
/// </summary>
table 76311 "PTV Planning Trace Node"
{
    Caption = 'Planning Traceability Node';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(2; "Node Text"; Text[100])
        {
            Caption = 'Node';
            DataClassification = CustomerContent;
        }
        field(3; "Document Type"; Enum "PTV Planning Source Type")
        {
            Caption = 'Document Type';
            DataClassification = CustomerContent;
        }
        field(4; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
        field(5; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(6; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
        }
        field(7; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
        }
        field(8; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
        field(9; "BOM Level"; Integer)
        {
            Caption = 'BOM Level';
            DataClassification = CustomerContent;
        }
        field(10; Indentation; Integer)
        {
            Caption = 'Indentation';
            DataClassification = CustomerContent;
        }
        field(11; "Forecast Date"; Date)
        {
            Caption = 'Forecast Date';
            DataClassification = CustomerContent;
        }
        field(12; "Profile Line No."; Integer)
        {
            Caption = 'Profile Line No.';
            DataClassification = CustomerContent;
        }
        field(13; "Worksheet Template Name"; Code[10])
        {
            Caption = 'Worksheet Template Name';
            DataClassification = CustomerContent;
        }
        field(14; "Journal Batch Name"; Code[10])
        {
            Caption = 'Journal Batch Name';
            DataClassification = CustomerContent;
        }
        field(15; "Parent Line No."; Integer)
        {
            Caption = 'Parent Line No.';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Profile; "Profile Line No.")
        {
        }
    }
}
