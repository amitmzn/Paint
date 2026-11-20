permissionset 76272 "PTV-PAINT-SHOPFLOOR"
{
    Access = Public;
    Assignable = true;
    Caption = 'Paint Shop Floor';
    Permissions =
        tabledata "PTV BOM Instruction" = R,
        tabledata "PTV Paint Setup" = R,
        tabledata "Production Order" = R,
        tabledata "PTV Planning Trace Entry" = R,
        tabledata "PTV Planning Trace Node" = RIMD,
        page "PTV BOM Instructions" = X,
        page "PTV Planning Trace Entries" = X,
        page "PTV Planning Trace FactBox" = X,
        page "PTV Planning Trace Tree" = X,
        report "PTV Batch Sheet" = X;
}
