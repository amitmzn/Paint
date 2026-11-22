page 76340 "PTV Planning Trace FactBox"
{
    Caption = 'Multi-Level Traceability';
    PageType = ListPart;
    SourceTable = "PTV Planning Trace Entry";
    ApplicationArea = All;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("BOM Level"; Rec."BOM Level")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the BOM level of this peg.';
                }
                field("Parent Document Type"; Rec."Parent Document Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the parent is a demand forecast, planning line, or production order.';
                }
                field("Parent Document No."; Rec."Parent Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the parent forecast, item, or production order.';
                }
                field("Parent Line No."; Rec."Parent Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the parent planning line number when the parent is still a worksheet line.';
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the item supplied by this peg.';
                }
                field("Pegged Quantity"; Rec."Pegged Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the quantity pegged from the parent to this supply.';
                }
                field("Root Forecast Name"; Rec."Root Forecast Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the demand forecast that started this chain.';
                }
                field("Root FG Item No."; Rec."Root FG Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the finished-good item at the root of this chain.';
                }
                field("Root FG Order No."; Rec."Root FG Order No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the finished-good production order created for the root item.';
                }
            }
        }
    }
}
