permissionset 76274 "PTV-PAINT-SALES"
{
    Access = Public;
    Assignable = true;
    Caption = 'Paint Sales';
    Permissions =
        tabledata "PTV Paint Product" = R,
        tabledata "PTV Shade" = R,
        tabledata "PTV Pack" = R,
        tabledata "Sales Shipment Line" = R,
        tabledata "PTV Paint Setup" = R,
        tabledata "PTV Fast Sales Store" = R,
        tabledata "PTV Fast Sales Cue" = RIMD,
        tabledata "User Setup" = R,
        tabledata "Item Reference" = R,
        tabledata "Item Tracking Code" = R,
        tabledata "Reservation Entry" = RIMD,
        tabledata "Lot No. Information" = RIMD,
        report "PTV OTIF Scorecard" = X,
        report "PTV Sales Margin by Product" = X,
        report "PTV Production vs Despatch" = X,
        codeunit "PTV UOM Mgt" = X,
        codeunit "PTV Sales PSP Propagation" = X,
        codeunit "PTV OTIF Subscriber" = X,
        codeunit "PTV Fast Sales Mgt" = X,
        page "PTV Fast Sales Invoice" = X,
        page "PTV Fast Sales Inv. Subform" = X,
        page "PTV Fast Sales Invoices" = X,
        page "PTV Fast Sales Headline" = X,
        page "PTV Fast Sales Activities" = X,
        page "PTV Fast Sales Role Center" = X,
        page "PTV Posted Fast Sales" = X,
        page "Item Tracking Lines" = X;
}
