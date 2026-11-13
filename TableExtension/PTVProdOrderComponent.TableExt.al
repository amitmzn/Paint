tableextension 76039 "PTV Prod. Order Component" extends "Prod. Order Component"
{
    fields
    {
        field(76000; "PTV Substitute"; Boolean)
        {
            Caption = 'Substitute';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(76001; "PTV Original Item No."; Code[20])
        {
            Caption = 'Original Item No.';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = Item."No.";
        }
        field(76002; "PTV Conversion Factor"; Decimal)
        {
            Caption = 'Conversion Factor';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
    }
}
