enum 77258 "PTV Payment Gate Mode"
{
    Extensible = true;
    Caption = 'Payment Gate Mode';

    value(0; None) { Caption = 'None'; }
    value(1; "Scheme Invoices") { Caption = 'Scheme-Eligible Invoices Only'; }
    value(2; "All Period Invoices") { Caption = 'All Period Invoices'; }
}
