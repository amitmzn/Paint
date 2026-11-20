page 77074 "PTV Subsidy List"
{
    ApplicationArea = All;
    Caption = 'Subsidy Schemes';
    CardPageId = "PTV Subsidy Card";
    Editable = false;
    PageType = List;
    SourceTable = "PTV Subsidy Header";
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(Code; Rec.Code)
                {
                    ToolTip = 'Specifies the subsidy code.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the subsidy description.';
                }
                field("Period Month"; Rec."Period Month")
                {
                    ToolTip = 'Specifies the period month.';
                }
                field("Period Year"; Rec."Period Year")
                {
                    ToolTip = 'Specifies the period year.';
                }
                field("Start Date"; Rec."Start Date")
                {
                    ToolTip = 'Specifies the subsidy evaluation start date.';
                }
                field("End Date"; Rec."End Date")
                {
                    ToolTip = 'Specifies the subsidy evaluation end date.';
                }
                field("Territory Filter"; Rec."Territory Filter")
                {
                    ToolTip = 'Specifies the territory filter.';
                }
                field(Status; Rec.Status)
                {
                    ToolTip = 'Specifies the subsidy status.';
                }
            }
        }
    }
}
