pageextension 76100 "PTV Item Card" extends "Item Card"
{
    layout
    {
        addlast(Content)
        {
            group("PTV Paint Specifications")
            {
                Caption = 'Paint Specifications';
                field("PTV Product Code"; Rec."PTV Product Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the paint formula.';
                }
                field("PTV Shade Code"; Rec."PTV Shade Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the shade.';
                }
                field("PTV Pack Code"; Rec."PTV Pack Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the pack. Validation maintains the container unit of measure.';
                }
                field("PTV Item Role"; Rec."PTV Item Role")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies how this item is used in paint manufacturing.';
                }
                field("PTV Specific Gravity"; Rec."PTV Specific Gravity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies kilograms per litre. One litre weighs this many kilograms.';
                }
                field("PTV Weight Per Litre"; Rec."PTV Weight Per Litre")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies kilograms per litre, kept equal to specific gravity.';
                }
                field("PTV Solids By Volume %"; Rec."PTV Solids By Volume %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies solids by volume percent.';
                }
                field("PTV Solids By Weight %"; Rec."PTV Solids By Weight %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies solids by weight percent.';
                }
                field("PTV Binder Content %"; Rec."PTV Binder Content %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies binder content percent.';
                }
                field("PTV VOC g/L"; Rec."PTV VOC g/L")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies volatile organic compound content in grams per litre.';
                }
                field("PTV VOC Category"; Rec."PTV VOC Category")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the VOC category code.';
                }
                field("PTV QC Enabled"; Rec."PTV QC Enabled")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies that receipts of this item require a quality inspection before invoicing.';
                }
                field("PTV QC Template Code"; Rec."PTV QC Template Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the standard quality inspection template for this item.';
                }
                field("PTV Shelf Life"; Rec."PTV Shelf Life")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the shelf life used with lot expiration.';
                }
                field("PTV Item Approved"; Rec."PTV Item Approved")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies that the item has been approved for use.';
                }
                field("PTV Created On"; Rec."PTV Created On")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the item was created.';
                }
                field("PTV Approved By"; Rec."PTV Approved By")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies who approved the item.';
                }
                field("PTV Approved On"; Rec."PTV Approved On")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the item was approved.';
                }
            }
        }
    }
}
