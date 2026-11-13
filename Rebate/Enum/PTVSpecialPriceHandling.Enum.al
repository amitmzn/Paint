enum 77268 "PTV Special Price Handling"
{
    Extensible = true;
    Caption = 'Special Price Handling';

    value(0; Allow) { Caption = 'Allow'; }
    value(1; "Exclude Line") { Caption = 'Exclude Special-Price Lines'; }
    value(2; "Exclude Customer") { Caption = 'Exclude Tie-Up / Special-Price Customers'; }
}
