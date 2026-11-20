permissionset 76273 "PTV-PAINT-LAB"
{
    Access = Public;
    Assignable = true;
    Caption = 'Paint Lab';
    Permissions =
        page "PTV Paint Role Center" = X,
        page "PTV Paint Headline" = X,
        page "PTV Paint Quick Links" = X,
        tabledata "PTV QC Paint Spec" = RIMD,
        tabledata "PTV Shade" = R,
        tabledata "Qlty. Inspection Header" = RM,
        tabledata "Qlty. Inspection Line" = RM,
        tabledata "Qlty. Test" = R,
        tabledata "Qlty. Inspection Result" = R,
        page "PTV QC Paint Specs" = X,
        page "PTV QC Paint Spec Subform" = X,
        report "PTV QC RFT Analysis" = X,
        codeunit "PTV QC Spec-Template Sync" = X,
        codeunit "PTV Rework Mgt" = X,
        codeunit "Qlty. Inspection - Create" = X;
}
