tableextension 77031 "PTV Rebate Sales Line" extends "Sales Line"
{
    fields
    {
        field(77000; "PTV FOC Item"; Boolean)
        {
            Caption = 'FOC Item';
            DataClassification = CustomerContent;
        }
        field(77001; "PTV Special Price"; Boolean)
        {
            Caption = 'Special Price';
            DataClassification = CustomerContent;
        }
        field(77002; "PTV Tie-Up Discount"; Boolean)
        {
            Caption = 'Tie-Up Discount';
            DataClassification = CustomerContent;
        }
    }
}
