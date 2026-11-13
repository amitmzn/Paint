permissionset 76271 "PTV-PAINT-CLERK"
{
    Access = Public;
    Assignable = true;
    Caption = 'Paint Clerk';
    Permissions =
        tabledata "PTV Paint Product" = RIMD,
        tabledata "PTV Shade" = RIMD,
        tabledata "PTV Pack" = RIMD,
        tabledata "PTV Mandatory Field Setup" = R,
        tabledata "PTV Paint Setup" = R,
        page "PTV Paint Products" = X,
        page "PTV Shades" = X,
        page "PTV Packs" = X,
        page "PTV Item Approval" = X,
        report "PTV SKU Matrix Request" = X,
        codeunit "PTV Item Approval Mgt" = X,
        codeunit "PTV Master Validation" = X,
        codeunit "PTV UOM Mgt" = X;
}
