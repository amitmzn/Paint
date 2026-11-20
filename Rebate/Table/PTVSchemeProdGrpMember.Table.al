table 77016 "PTV Scheme Prod. Grp. Member"
{
    Caption = 'Scheme Product Group Member';
    DataClassification = CustomerContent;

    fields
    {
        field(77000; "Group Code"; Code[20])
        {
            Caption = 'Group Code';
            DataClassification = CustomerContent;
            TableRelation = "PTV Scheme Product Group".Code;
        }
        field(77001; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(77002; "Line Type"; Enum "PTV Scheme Line Type")
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
        }
        field(77003; "Paint Product Code"; Code[20])
        {
            Caption = 'Paint Product Code';
            DataClassification = CustomerContent;
            TableRelation = "PTV Paint Product".Code;
        }
        field(77004; "Item Category Code"; Code[20])
        {
            Caption = 'Item Category Code';
            DataClassification = CustomerContent;
            TableRelation = "Item Category".Code;
        }
        field(77005; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item."No.";
        }
        field(77006; "Pack Code"; Code[20])
        {
            Caption = 'Pack Code';
            DataClassification = CustomerContent;
            TableRelation = "PTV Pack".Code;
        }
        field(77007; "Shade Code"; Code[20])
        {
            Caption = 'Shade Code';
            DataClassification = CustomerContent;
            TableRelation = "PTV Shade".Code;
        }
    }

    keys
    {
        key(PK; "Group Code", "Line No.")
        {
            Clustered = true;
        }
        key(GroupType; "Group Code", "Line Type")
        {
        }
    }
}
