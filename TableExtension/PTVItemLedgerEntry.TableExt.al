tableextension 76047 "PTV Item Ledger Entry" extends "Item Ledger Entry"
{
    fields
    {
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
}
