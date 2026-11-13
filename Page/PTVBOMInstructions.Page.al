page 76067 "PTV BOM Instructions"
{
    ApplicationArea = All;
    Caption = 'BOM Instructions';
    PageType = ListPart;
    SourceTable = "PTV BOM Instruction";
    AutoSplitKey = true;
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Step No."; Rec."Step No.")
                {
                    ToolTip = 'Specifies the shop-floor step number.';
                }
                field(Instruction; Rec.Instruction)
                {
                    ToolTip = 'Specifies the processing instruction.';
                }
                field("Min Temp C"; Rec."Min Temp C")
                {
                    ToolTip = 'Specifies the minimum temperature in degrees Celsius.';
                }
                field("Max Temp C"; Rec."Max Temp C")
                {
                    ToolTip = 'Specifies the maximum temperature in degrees Celsius.';
                }
                field("Agitation RPM"; Rec."Agitation RPM")
                {
                    ToolTip = 'Specifies the agitation speed.';
                }
                field("Duration Min"; Rec."Duration Min")
                {
                    ToolTip = 'Specifies the step duration in minutes.';
                }
                field("QC Checkpoint"; Rec."QC Checkpoint")
                {
                    ToolTip = 'Specifies that this step is an in-process quality checkpoint.';
                }
            }
        }
    }
}
