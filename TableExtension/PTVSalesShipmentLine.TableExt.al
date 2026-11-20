tableextension 76034 "PTV Sales Shipment Line" extends "Sales Shipment Line"
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
        field(76004; "PTV On Time"; Boolean)
        {
            Caption = 'On Time';
            DataClassification = CustomerContent;
        }
        field(76005; "PTV In Full"; Boolean)
        {
            Caption = 'In Full';
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
        key(PTVOTIF; "PTV On Time", "PTV In Full")
        {
        }
    }
}
