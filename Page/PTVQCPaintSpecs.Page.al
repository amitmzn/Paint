page 76068 "PTV QC Paint Specs"
{
    ApplicationArea = All;
    Caption = 'QC Paint Specs';
    PageType = List;
    SourceTable = "PTV QC Paint Spec";
    UsageCategory = Lists;
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies the item the limits belong to.';
                }
                field("Shade Code"; Rec."Shade Code")
                {
                    ToolTip = 'Specifies the shade. Leave it blank for an item-level limit.';
                }
                field("Test Code"; Rec."Test Code")
                {
                    ToolTip = 'Specifies the standard quality test.';
                }
                field(Version; Rec.Version)
                {
                    ToolTip = 'Specifies the specification version.';
                }
                field(Target; Rec.Target)
                {
                    ToolTip = 'Specifies the target value.';
                }
                field("Min Limit"; Rec."Min Limit")
                {
                    ToolTip = 'Specifies the minimum accepted value.';
                }
                field("Max Limit"; Rec."Max Limit")
                {
                    ToolTip = 'Specifies the maximum accepted value.';
                }
                field("Mandatory Pass"; Rec."Mandatory Pass")
                {
                    ToolTip = 'Specifies that a pass result is required for this test.';
                }
                field(Status; Rec.Status)
                {
                    ToolTip = 'Specifies whether the limit is draft, certified, or closed.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(SyncTemplate)
            {
                ApplicationArea = All;
                Caption = 'Sync Template';
                Image = Template;
                ToolTip = 'Creates or updates the standard quality inspection template from the certified specification.';

                trigger OnAction()
                var
                    Spec: Record "PTV QC Paint Spec";
                    Sync: Codeunit "PTV QC Spec-Template Sync";
                begin
                    CurrPage.SetSelectionFilter(Spec);
                    Sync.SyncSpecSet(Spec);
                end;
            }
        }
    }
}
