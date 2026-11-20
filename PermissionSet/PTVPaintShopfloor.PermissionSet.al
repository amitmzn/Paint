permissionset 76272 "PTV-PAINT-SHOPFLOOR"
{
    Access = Public;
    Assignable = true;
    Caption = 'Paint Shop Floor';
    Permissions =
        page "PTV Paint Role Center" = X,
        page "PTV Paint Headline" = X,
        page "PTV Paint Quick Links" = X,
        tabledata "PTV BOM Instruction" = R,
        tabledata "PTV Paint Setup" = R,
        tabledata "PTV Pack" = R,
        tabledata "Item Unit of Measure" = R,
        codeunit "PTV UOM Mgt" = X,
        tabledata "Production Order" = R,
        page "PTV BOM Instructions" = X,
        report "PTV Batch Sheet" = X;
}
