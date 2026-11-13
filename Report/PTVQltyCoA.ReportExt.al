reportextension 76195 "PTV Qlty. CoA" extends "Qlty. Certificate of Analysis"
{
    dataset
    {
        add(CurrentInspection)
        {
            column(PTV_Shade_Code; PTVShadeCode) { }
            column(PTV_Specific_Gravity; PTVSpecificGravity) { }
            column(PTV_VOC_gL; PTVVoc) { }
            column(PTV_Solids_By_Weight; PTVSolidsWeight) { }
            column(PTV_DeltaE_Target; "PTV Delta E Target") { }
            column(PTV_DeltaE_Max; "PTV Delta E Max") { }
            column(PTV_Lab_L; PTVLabL) { }
            column(PTV_Lab_a; PTVLaba) { }
            column(PTV_Lab_b; PTVLabb) { }
        }
        modify(CurrentInspection)
        {
            trigger OnAfterAfterGetRecord()
            var
                Item: Record Item;
                Shade: Record "PTV Shade";
            begin
                PTVShadeCode := "PTV Shade Code";
                PTVSpecificGravity := 0;
                PTVVoc := 0;
                PTVSolidsWeight := 0;
                PTVLabL := 0;
                PTVLaba := 0;
                PTVLabb := 0;
                Item.SetLoadFields("PTV Specific Gravity", "PTV VOC g/L", "PTV Solids By Weight %", "PTV Shade Code");
                if Item.Get("Source Item No.") then begin
                    if PTVShadeCode = '' then
                        PTVShadeCode := Item."PTV Shade Code";
                    PTVSpecificGravity := Item."PTV Specific Gravity";
                    PTVVoc := Item."PTV VOC g/L";
                    PTVSolidsWeight := Item."PTV Solids By Weight %";
                end;
                Shade.SetLoadFields("Lab L Target", "Lab a Target", "Lab b Target");
                if Shade.Get(PTVShadeCode) then begin
                    PTVLabL := Shade."Lab L Target";
                    PTVLaba := Shade."Lab a Target";
                    PTVLabb := Shade."Lab b Target";
                end;
            end;
        }
    }

    rendering
    {
        layout(PTVCoA)
        {
            Type = RDLC;
            LayoutFile = './layout/PTVCertificateOfAnalysis.rdlc';
            Caption = 'Paint Certificate of Analysis';
        }
    }

    var
        PTVShadeCode: Code[20];
        PTVSpecificGravity: Decimal;
        PTVVoc: Decimal;
        PTVSolidsWeight: Decimal;
        PTVLabL: Decimal;
        PTVLaba: Decimal;
        PTVLabb: Decimal;
}
