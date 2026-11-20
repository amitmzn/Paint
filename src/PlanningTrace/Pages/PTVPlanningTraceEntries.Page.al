page 76342 "PTV Planning Trace Entries"
{
    Caption = 'Planning Traceability Entries';
    PageType = List;
    SourceTable = "PTV Planning Trace Entry";
    ApplicationArea = All;
    UsageCategory = Lists;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the ledger entry number.';
                }
                field("Root Forecast Name"; Rec."Root Forecast Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the demand forecast that started this chain.';
                }
                field("Root Forecast Date"; Rec."Root Forecast Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the forecast date of the root demand.';
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
                field("Parent Document Type"; Rec."Parent Document Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the parent document type.';
                }
                field("Parent Document No."; Rec."Parent Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the parent document number.';
                }
                field("Parent Line No."; Rec."Parent Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the parent line number.';
                }
                field("Child Document Type"; Rec."Child Document Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the child document type.';
                }
                field("Child Document No."; Rec."Child Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the child document number.';
                }
                field("Child Line No."; Rec."Child Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the child line number.';
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the item on the child supply.';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the variant on the child supply.';
                }
                field("Pegged Quantity"; Rec."Pegged Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the quantity pegged from the parent to the child.';
                }
                field("BOM Level"; Rec."BOM Level")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the BOM level of the child supply.';
                }
                field("Created DateTime"; Rec."Created DateTime")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when this peg was recorded.';
                }
            }
        }
    }
}
