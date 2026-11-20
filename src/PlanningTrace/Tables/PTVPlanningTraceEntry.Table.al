/// <summary>
/// Stores one parent-child supply peg for multi-level planning traceability.
/// </summary>
table 76310 "PTV Planning Trace Entry"
{
    Caption = 'Planning Traceability Entry';
    DataClassification = CustomerContent;
    DrillDownPageId = "PTV Planning Trace Entries";
    LookupPageId = "PTV Planning Trace Entries";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(2; "Root Forecast Name"; Code[20])
        {
            Caption = 'Root Forecast Name';
            DataClassification = CustomerContent;
            TableRelation = "Production Forecast Name".Name;
        }
        field(3; "Root Forecast Date"; Date)
        {
            Caption = 'Root Forecast Date';
            DataClassification = CustomerContent;
        }
        field(4; "Root FG Item No."; Code[20])
        {
            Caption = 'Root FG Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item."No.";
        }
        field(5; "Root FG Order No."; Code[20])
        {
            Caption = 'Root FG Order No.';
            DataClassification = CustomerContent;
        }
        field(10; "Parent Document Type"; Enum "PTV Planning Source Type")
        {
            Caption = 'Parent Document Type';
            DataClassification = CustomerContent;
        }
        field(11; "Parent Document No."; Code[20])
        {
            Caption = 'Parent Document No.';
            DataClassification = CustomerContent;
        }
        field(12; "Parent Line No."; Integer)
        {
            Caption = 'Parent Line No.';
            DataClassification = CustomerContent;
        }
        field(13; "Parent Wksh. Template Name"; Code[10])
        {
            Caption = 'Parent Worksheet Template Name';
            DataClassification = CustomerContent;
        }
        field(14; "Parent Wksh. Batch Name"; Code[10])
        {
            Caption = 'Parent Worksheet Batch Name';
            DataClassification = CustomerContent;
        }
        field(20; "Child Document Type"; Enum "PTV Planning Source Type")
        {
            Caption = 'Child Document Type';
            DataClassification = CustomerContent;
        }
        field(21; "Child Document No."; Code[20])
        {
            Caption = 'Child Document No.';
            DataClassification = CustomerContent;
        }
        field(22; "Child Line No."; Integer)
        {
            Caption = 'Child Line No.';
            DataClassification = CustomerContent;
        }
        field(23; "Child Wksh. Template Name"; Code[10])
        {
            Caption = 'Child Worksheet Template Name';
            DataClassification = CustomerContent;
        }
        field(24; "Child Wksh. Batch Name"; Code[10])
        {
            Caption = 'Child Worksheet Batch Name';
            DataClassification = CustomerContent;
        }
        field(30; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item."No.";
        }
        field(31; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            DataClassification = CustomerContent;
            TableRelation = "Item Variant".Code where("Item No." = field("Item No."));
        }
        field(32; "Pegged Quantity"; Decimal)
        {
            Caption = 'Pegged Quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
        field(33; "BOM Level"; Integer)
        {
            Caption = 'BOM Level';
            DataClassification = CustomerContent;
        }
        field(40; "Created DateTime"; DateTime)
        {
            Caption = 'Created DateTime';
            DataClassification = CustomerContent;
        }
        field(50; "Supply Profile Line No."; Integer)
        {
            Caption = 'Supply Profile Line No.';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Root; "Root FG Item No.", "Root FG Order No.", "Root Forecast Name")
        {
        }
        key(ParentDoc; "Parent Document Type", "Parent Document No.", "Parent Line No.")
        {
        }
        key(ParentWksh; "Parent Document Type", "Parent Wksh. Template Name", "Parent Wksh. Batch Name", "Parent Line No.")
        {
        }
        key(ChildWksh; "Child Document Type", "Child Wksh. Template Name", "Child Wksh. Batch Name", "Child Line No.")
        {
        }
        key(ChildOrder; "Child Document Type", "Child Document No.", "Child Line No.")
        {
        }
    }
}
