pageextension 76108 "PTV Qlty. Inspection" extends "Qlty. Inspection"
{
    layout
    {
        addlast(Content)
        {
            group(PTVPaint)
            {
                Caption = 'Paint';
                field("PTV Shade Code"; Rec."PTV Shade Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the shade snapshotted when the inspection was created.';
                }
                field("PTV Delta E Target"; Rec."PTV Delta E Target")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the delta E target snapshotted from the shade.';
                }
                field("PTV Delta E Min"; Rec."PTV Delta E Min")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the minimum delta E snapshotted from the certified specification.';
                }
                field("PTV Delta E Max"; Rec."PTV Delta E Max")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the maximum delta E snapshotted from the shade or specification.';
                }
                field("PTV Specific Gravity"; Rec."PTV Specific Gravity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the item specific gravity.';
                }
                field("PTV VOC g/L"; Rec."PTV VOC g/L")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the item VOC in grams per litre.';
                }
                field("PTV Solids By Weight %"; Rec."PTV Solids By Weight %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the item solids by weight percent.';
                }
            }
        }
    }

    actions
    {
        addlast(Processing)
        {
            action(PTVSuggestRework)
            {
                ApplicationArea = All;
                Caption = 'Suggest Rework';
                Image = CreateDocument;
                ToolTip = 'When the result is REWORK, creates a rework production order that consumes the failed lot.';

                trigger OnAction()
                var
                    ReworkMgt: Codeunit "PTV Rework Mgt";
                begin
                    ReworkMgt.SuggestReworkFromInspection(Rec);
                end;
            }
        }
    }
}
