page 77063 "PTV Scheme List"
{
    ApplicationArea = All;
    Caption = 'Rebate Schemes';
    PageType = List;
    SourceTable = "PTV Scheme Header";
    CardPageId = "PTV Scheme Card";
    UsageCategory = Lists;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field(Code; Rec.Code)
                {
                    ToolTip = 'Specifies the scheme code.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the scheme description.';
                }
                field("Reference No."; Rec."Reference No.")
                {
                    ToolTip = 'Specifies the circular or memo reference number.';
                }
                field("Scheme Type"; Rec."Scheme Type")
                {
                    ToolTip = 'Specifies the scheme type.';
                }
                field("Evaluation Period"; Rec."Evaluation Period")
                {
                    ToolTip = 'Specifies the evaluation frequency.';
                }
                field("Start Date"; Rec."Start Date")
                {
                    ToolTip = 'Specifies the start date.';
                }
                field("End Date"; Rec."End Date")
                {
                    ToolTip = 'Specifies the end date.';
                }
                field(Status; Rec.Status)
                {
                    ToolTip = 'Specifies the scheme status.';
                }
                field("No. of Lines"; Rec."No. of Lines")
                {
                    ToolTip = 'Specifies the number of lines on the scheme.';
                }
                field("No. of Slabs"; Rec."No. of Slabs")
                {
                    ToolTip = 'Specifies the number of slabs on the scheme.';
                }
            }
        }
    }
}
