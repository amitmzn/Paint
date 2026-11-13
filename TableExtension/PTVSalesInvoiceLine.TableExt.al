tableextension 76033 "PTV Sales Invoice Line" extends "Sales Invoice Line"
{
    fields
    {
        field(76000; "PTV Product Code"; Code[20])
        {
            Caption = 'Paint Product Code';
            DataClassification = CustomerContent;
        }
        field(76001; "PTV Shade Code"; Code[20])
        {
            Caption = 'Shade Code';
            DataClassification = CustomerContent;
        }
        field(76002; "PTV Pack Code"; Code[20])
        {
            Caption = 'Pack Code';
            DataClassification = CustomerContent;
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
