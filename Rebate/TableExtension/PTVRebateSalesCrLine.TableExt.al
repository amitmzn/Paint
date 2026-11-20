tableextension 77033 "PTV Rebate Sales Cr.Line" extends "Sales Cr.Memo Line"
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
        key(PTVRebateCrCustomerDate; "Sell-to Customer No.", "Posting Date", Type)
        {
        }
    }
}
