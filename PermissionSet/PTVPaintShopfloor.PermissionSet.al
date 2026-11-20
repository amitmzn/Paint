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
        tabledata "PTV Planning Trace Entry" = R,
        tabledata "PTV Planning Trace Node" = RIMD,
        page "PTV BOM Instructions" = X,
        page "PTV Planning Trace Entries" = X,
        page "PTV Planning Trace FactBox" = X,
        page "PTV Planning Trace Tree" = X,
        report "PTV Batch Sheet" = X;
}
