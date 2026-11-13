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
    }

    keys
    {
        key(PTVOTIF; "PTV On Time", "PTV In Full")
        {
        }
    }
}
