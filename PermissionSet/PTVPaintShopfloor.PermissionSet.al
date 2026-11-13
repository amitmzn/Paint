permissionset 76272 "PTV-PAINT-SHOPFLOOR"
{
    Access = Public;
    Assignable = true;
    Caption = 'Paint Shop Floor';
    Permissions =
        tabledata "PTV BOM Instruction" = R,
        tabledata "PTV Paint Setup" = R,
        tabledata "Production Order" = R,
        page "PTV BOM Instructions" = X,
        report "PTV Batch Sheet" = X;
}
