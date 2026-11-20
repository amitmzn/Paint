table 77004 "PTV Scheme Slab"
{
    Caption = 'Rebate Scheme Slab';
    DataClassification = CustomerContent;

    fields
    {
        field(77000; "Scheme Code"; Code[20])
        {
            Caption = 'Scheme Code';
            DataClassification = CustomerContent;
            TableRelation = "PTV Scheme Header".Code;
        }
        field(77001; "Scheme Line No."; Integer)
        {
            Caption = 'Scheme Line No.';
            DataClassification = CustomerContent;
        }
        field(77002; "Slab No."; Integer)
        {
            Caption = 'Slab No.';
            DataClassification = CustomerContent;
        }
        field(77003; "From Quantity"; Decimal)
        {
            Caption = 'From Quantity';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(77004; "To Quantity"; Decimal)
        {
            Caption = 'To Quantity';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(77005; "From Value"; Decimal)
        {
            Caption = 'From Value';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(77006; "To Value"; Decimal)
        {
            Caption = 'To Value';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(77007; "Min Growth %"; Decimal)
        {
            Caption = 'Min Growth %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
        }
        field(77008; "Discount Type"; Enum "PTV Rebate Discount Type")
        {
            Caption = 'Reward / Discount Type';
            DataClassification = CustomerContent;
        }
        field(77009; "Discount %"; Decimal)
        {
            Caption = 'Discount %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 4;
            MinValue = 0;
        }
        field(77010; "Discount Amount"; Decimal)
        {
            Caption = 'Fixed CN / Amount';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(77011; "Rate per Unit"; Decimal)
        {
            Caption = 'Rate per Unit (Rs./Kg-Ltr)';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 4;
            MinValue = 0;
        }
        field(77012; "Trip Description"; Text[100])
        {
            Caption = 'Trip / Non-Monetary Option';
            DataClassification = CustomerContent;
        }
        field(77013; "Multiple Base Value"; Decimal)
        {
            Caption = 'Multiple Base Value';
            DataClassification = CustomerContent;
            MinValue = 0;
            ToolTip = 'Optional threshold value for awarding fixed CN in multiples (e.g., 13,00,000).';
        }
        field(77014; "Allow Base Multiples"; Boolean)
        {
            Caption = 'Award Base CN in Multiples';
            DataClassification = CustomerContent;
        }
        field(77015; "Incremental Step Value"; Decimal)
        {
            Caption = 'Incremental Step Value';
            DataClassification = CustomerContent;
            MinValue = 0;
            ToolTip = 'Every additional X sales value above From/Base Value earns Incremental Bonus Amount (e.g., 1,00,000).';
        }
        field(77016; "Incremental Bonus Amount"; Decimal)
        {
            Caption = 'Incremental Bonus Amount';
            DataClassification = CustomerContent;
            MinValue = 0;
            ToolTip = 'Extra credit note amount per Incremental Step Value (e.g., 7,000).';
        }
        field(77017; "FOC Item No."; Code[20])
        {
            Caption = 'FOC Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item."No.";
        }
        field(77018; "FOC Unit of Measure"; Code[10])
        {
            Caption = 'FOC Unit of Measure';
            DataClassification = CustomerContent;
            TableRelation = "Unit of Measure".Code;
        }
        field(77019; "FOC Quantity"; Decimal)
        {
            Caption = 'FOC Quantity';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(77020; "Proportional FOC"; Boolean)
        {
            Caption = 'Proportional FOC';
            DataClassification = CustomerContent;
        }
        field(77021; "Incremental Qty"; Decimal)
        {
            Caption = 'Incremental Qty';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(77022; "Incremental FOC Qty"; Decimal)
        {
            Caption = 'Incremental FOC Qty';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(77023; "Qualification Tier Code"; Code[20])
        {
            Caption = 'Qualification Tier Code';
            DataClassification = CustomerContent;
            TableRelation = "PTV Qualification Tier".Code;
        }
        field(77024; "FOC Buy Quantity"; Decimal)
        {
            Caption = 'FOC Buy Quantity';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(77025; "FOC Complete Blocks Only"; Boolean)
        {
            Caption = 'FOC Complete Blocks Only';
            DataClassification = CustomerContent;
        }
        field(77026; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer."No.";
        }
    }

    keys
    {
        key(PK; "Scheme Code", "Scheme Line No.", "Slab No.")
        {
            Clustered = true;
        }
        key(ValueRange; "Scheme Code", "Scheme Line No.", "From Value")
        {
        }
        key(QtyRange; "Scheme Code", "Scheme Line No.", "From Quantity")
        {
        }
    }
}
