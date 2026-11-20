page 77072 "PTV Scheme Prod. Group Card"
{
    ApplicationArea = All;
    Caption = 'Scheme Product Group Card';
    PageType = Card;
    SourceTable = "PTV Scheme Product Group";

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

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
                    ToolTip = 'Specifies the product segment.';
                }
                field("Rebate Measure"; Rec."Rebate Measure")
                {
                    ToolTip = 'Specifies how quantities are measured for this group.';
                }
                field("Default Min Growth %"; Rec."Default Min Growth %")
                {
                    ToolTip = 'Specifies the default YoY growth requirement.';
                }
                field(Blocked; Rec.Blocked)
                {
                    ToolTip = 'Specifies whether the group is blocked.';
                }
            }
            part(Members; "PTV Scheme Prod. Grp. Members")
            {
                Caption = 'Include / Exclude Members';
                SubPageLink = "Group Code" = field(Code);
            }
        }
    }
}
