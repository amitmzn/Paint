tableextension 77030 "PTV Rebate Customer" extends Customer
{
    fields
    {
        field(77000; "PTV Trade Channel"; Enum "PTV Trade Channel")
        {
            Caption = 'Trade Channel';
            DataClassification = CustomerContent;
        }
        field(77001; "PTV Tie-Up Discount Opted"; Boolean)
        {
            Caption = 'Tie-Up Discount Opted';
            DataClassification = CustomerContent;
        }
        field(77002; "PTV Depot Location Code"; Code[10])
        {
            Caption = 'Depot Location Code';
            DataClassification = CustomerContent;
            TableRelation = Location.Code;
        }
    }
}
