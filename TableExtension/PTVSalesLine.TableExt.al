tableextension 76032 "PTV Sales Line" extends "Sales Line"
{
    fields
    {
        field(76000; "PTV Product Code"; Code[20])
        {
            Caption = 'Paint Product Code';
            DataClassification = CustomerContent;
            TableRelation = "PTV Paint Product".Code;
        }
        field(76001; "PTV Shade Code"; Code[20])
        {
            Caption = 'Shade Code';
            DataClassification = CustomerContent;
            TableRelation = "PTV Shade".Code;
        }
        field(76002; "PTV Pack Code"; Code[20])
        {
            Caption = 'Pack Code';
            DataClassification = CustomerContent;
            TableRelation = "PTV Pack".Code;
        }
        field(76003; "PTV Promised Delivery Date"; Date)
        {
            Caption = 'Promised Delivery Date';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PTVProductShade; "PTV Product Code", "PTV Shade Code")
        {
        }
    }
}
