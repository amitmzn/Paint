tableextension 77032 "PTV Rebate Sales Inv. Line" extends "Sales Invoice Line"
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

    keys
    {
        key(PTVRebateCustomerDate; "Sell-to Customer No.", "Posting Date", Type)
        {
        }
    }
}
