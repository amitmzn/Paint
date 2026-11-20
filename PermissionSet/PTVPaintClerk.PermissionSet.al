permissionset 76271 "PTV-PAINT-CLERK"
{
    Access = Public;
    Assignable = true;
    Caption = 'Paint Clerk';
    Permissions =
        page "PTV Paint Role Center" = X,
        page "PTV Paint Headline" = X,
        page "PTV Paint Quick Links" = X,
        tabledata "PTV Paint Product" = RIMD,
        tabledata "PTV Shade" = RIMD,
        tabledata "PTV Pack" = RIMD,
        tabledata "PTV Instruction Master" = R,
        tabledata "PTV Mandatory Field Setup" = R,
        tabledata "PTV Paint Setup" = R,
        page "PTV Paint Products" = X,
        page "PTV Shades" = X,
        page "PTV Packs" = X,
        page "PTV Instruction Master" = X,
        page "PTV Item Approval" = X,
        table "PTV Instruction Master" = X,
        report "PTV SKU Matrix Request" = X,
        codeunit "PTV Item Approval Mgt" = X,
        codeunit "PTV Master Validation" = X,
        codeunit "PTV UOM Mgt" = X;
}
