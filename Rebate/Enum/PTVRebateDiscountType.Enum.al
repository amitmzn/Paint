enum 77262 "PTV Rebate Discount Type"
{
    Extensible = true;
    Caption = 'Rebate Discount Type';

    value(0; Percentage) { Caption = 'Percentage'; }
    value(1; "Fixed Amount") { Caption = 'Fixed Amount'; }
    value(2; "Rate per Unit") { Caption = 'Rate per Unit (Kg/Ltr)'; }
    value(3; "FOC Quantity") { Caption = 'FOC Quantity'; }
    value(4; "Trip or Fixed CN") { Caption = 'Trip or Fixed Credit Note'; }
}
