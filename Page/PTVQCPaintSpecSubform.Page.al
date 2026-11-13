page 76069 "PTV QC Paint Spec Subform"
{
    ApplicationArea = All;
    Caption = 'QC Paint Spec Lines';
    PageType = ListPart;
    SourceTable = "PTV QC Paint Spec";
    AutoSplitKey = false;
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
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
}
