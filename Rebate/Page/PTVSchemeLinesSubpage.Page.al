page 77064 "PTV Scheme Lines Subpage"
{
    ApplicationArea = All;
    Caption = 'Scheme Lines';
    PageType = ListPart;
    SourceTable = "PTV Scheme Line";
    AutoSplitKey = true;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Line Type"; Rec."Line Type")
                {
                    ToolTip = 'Specifies whether this line includes or excludes matching items.';
                }
                field("Scheme Product Group"; Rec."Scheme Product Group")
                {
                    ToolTip = 'Specifies the scheme product group.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the line description.';
                }
                field("Paint Product Code"; Rec."Paint Product Code")
                {
                    ToolTip = 'Optional paint product filter.';
                }
                field("Item Category Code"; Rec."Item Category Code")
                {
                    ToolTip = 'Optional item category filter.';
                }
                field("Rebate Measure"; Rec."Rebate Measure")
                {
                    ToolTip = 'Specifies whether quantity is measured in Litres, Kg, or Auto.';
                }
                field("Min Growth %"; Rec."Min Growth %")
                {
                    ToolTip = 'Specifies the minimum YoY growth percentage for this line.';
                }
                field("Minimum Quantity"; Rec."Minimum Quantity")
                {
                    ToolTip = 'Specifies the minimum quantity required.';
                }
                field("Shade Code"; Rec."Shade Code")
                {
                    ToolTip = 'Specifies the shade code.';
                }
                field("Pack Code"; Rec."Pack Code")
                {
                    ToolTip = 'Specifies the pack code.';
                }
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies the item no..';
                }
                field("Sales UOM Filter"; Rec."Sales UOM Filter")
                {
                    ToolTip = 'Specifies the sales uom filter.';
                }
                field("Item Discount Group Filter"; Rec."Item Discount Group Filter")
                {
                    ToolTip = 'Specifies the item discount group filter.';
                }
                field("Minimum Value"; Rec."Minimum Value")
                {
                    ToolTip = 'Specifies the minimum value.';
                }
                field("Target Quantity"; Rec."Target Quantity")
                {
                    ToolTip = 'Specifies the target quantity.';
                }
                field("Target Value"; Rec."Target Value")
                {
                    ToolTip = 'Specifies the target value.';
                }
                field("Paint Product Filter"; Rec."Paint Product Filter")
                {
                    ToolTip = 'Specifies the paint product filter.';
                }
                field("Shade Filter"; Rec."Shade Filter")
                {
                    ToolTip = 'Specifies the shade filter.';
                }
                field("Pack Filter"; Rec."Pack Filter")
                {
                    ToolTip = 'Specifies the pack filter.';
                }
                field("No. of Slabs"; Rec."No. of Slabs")
                {
                    ToolTip = 'Specifies the number of slabs linked to this line.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(OpenLineSlabs)
            {
                Caption = 'Line Slabs';
                Image = Discount;
                ToolTip = 'Open slabs for the selected scheme line.';

                trigger OnAction()
                var
                    Slab: Record "PTV Scheme Slab";
                begin
                    Slab.SetRange("Scheme Code", Rec."Scheme Code");
                    Slab.SetRange("Scheme Line No.", Rec."Line No.");
                    Page.RunModal(Page::"PTV Scheme Slabs", Slab);
                end;
            }
        }
    }
}
