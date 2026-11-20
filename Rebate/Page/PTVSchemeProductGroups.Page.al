page 77061 "PTV Scheme Product Groups"
{
    ApplicationArea = All;
    Caption = 'Scheme Product Groups';
    PageType = List;
    SourceTable = "PTV Scheme Product Group";
    CardPageId = "PTV Scheme Prod. Group Card";
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
                    ToolTip = 'Specifies the scheme product group code.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the description of the scheme product group.';
                }
                field("Product Segment"; Rec."Product Segment")
                {
                    ToolTip = 'Specifies the product segment used for mix tracking.';
                }
                field("Rebate Measure"; Rec."Rebate Measure")
                {
                    ToolTip = 'Specifies whether quantities are measured in Litres, Kilograms, or automatically.';
                }
                field("Default Min Growth %"; Rec."Default Min Growth %")
                {
                    ToolTip = 'Specifies the default YoY minimum growth percentage.';
                }
                field(Blocked; Rec.Blocked)
                {
                    ToolTip = 'Specifies whether the group is blocked.';
                }
            }
        }
    }
}
