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
        report "PTV OTIF Scorecard" = X,
        report "PTV Sales Margin by Product" = X,
        report "PTV Production vs Despatch" = X,
        codeunit "PTV UOM Mgt" = X,
        codeunit "PTV Sales PSP Propagation" = X,
        codeunit "PTV OTIF Subscriber" = X;
}
