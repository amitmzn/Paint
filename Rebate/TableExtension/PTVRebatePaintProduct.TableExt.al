tableextension 77034 "PTV Rebate Paint Product" extends "PTV Paint Product"
{
    fields
    {
        field(77000; "PTV Product Segment"; Enum "PTV Product Segment")
        {
            Caption = 'Product Segment';
            DataClassification = CustomerContent;
        }
        field(77001; "PTV Rebate Measure"; Enum "PTV Rebate Measure")
        {
            Caption = 'Rebate Measure';
            DataClassification = CustomerContent;
        }
    }
}
