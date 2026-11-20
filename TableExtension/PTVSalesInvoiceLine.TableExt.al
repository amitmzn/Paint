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
        field(76006; "PTV Quantity Litres"; Decimal)
        {
            Caption = 'Qty. in Litres';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(76007; "PTV Litres per Base Unit"; Decimal)
        {
            Caption = 'Litres per Base Unit';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
    }

    keys
    {
        key(PTVProductShade; "PTV Product Code", "PTV Shade Code")
        {
        }
    }
}
