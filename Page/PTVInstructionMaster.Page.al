page 76081 "PTV Instruction Master"
{
    ApplicationArea = All;
    Caption = 'Instruction Master';
    PageType = List;
    SourceTable = "PTV Instruction Master";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Code"; Rec."Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unique code for this standard instruction.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the short description of this instruction.';
                }
                field("Standard Instruction Text"; Rec."Standard Instruction Text")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the full manufacturing instruction text to be copied to the BOM.';
                }
                field("Min Temp C"; Rec."Min Temp C")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the default minimum process temperature in degrees Celsius.';
                }
                field("Max Temp C"; Rec."Max Temp C")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the default maximum process temperature in degrees Celsius.';
                }
                field("Agitation RPM"; Rec."Agitation RPM")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the default mixer or agitator speed in RPM.';
                }
                field("Duration Min"; Rec."Duration Min")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the default process duration in minutes.';
                }
                field("QC Checkpoint"; Rec."QC Checkpoint")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if this process step represents a mandatory quality control checkpoint.';
                }
            }
        }
    }
}
