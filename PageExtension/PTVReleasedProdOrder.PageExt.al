pageextension 76106 "PTV Released Production Order" extends "Released Production Order"
{
    layout
    {
        addlast(General)
        {
            field("PTV Batch No."; Rec."PTV Batch No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the batch number. It is also the finished-goods lot number.';
            }
            field("PTV Formula No."; Rec."PTV Formula No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the formula.';
            }
            field("PTV Shade Code"; Rec."PTV Shade Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the shade.';
            }
            field("PTV Specific Gravity"; Rec."PTV Specific Gravity")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the specific gravity snapshotted at release.';
            }
            field("PTV Rework Order"; Rec."PTV Rework Order")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies that this order reworks a failed lot.';
            }
            field("PTV Original Batch No."; Rec."PTV Original Batch No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the failed batch consumed by this rework order.';
            }
            field("PTV Latest Insp. Result"; Rec."PTV Latest Insp. Result")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the latest quality result for this batch lot.';
            }
            field("PTV Root Demand Forecast"; Rec."PTV Root Demand Forecast")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the demand forecast that originated this production order.';
            }
            field("PTV Parent Source Type"; Rec."PTV Parent Source Type")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies whether the immediate parent is a demand forecast, planning line, or production order.';
            }
            field(PTVParentSourceCaption; ParentSourceCaption)
            {
                ApplicationArea = All;
                Caption = 'Parent Source Order No.';
                Editable = false;
                ToolTip = 'Specifies the immediate parent order or forecast. When more than one parent is pegged, the value is Multiple (Drill-down).';

                trigger OnDrillDown()
                var
                    TraceMgt: Codeunit "PTV Planning Trace Mgt";
                begin
                    TraceMgt.OpenTreeForProdOrder(Rec);
                end;
            }
            field("PTV Root FG Prod. Order No."; Rec."PTV Root FG Prod. Order No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the finished-good production order at the root of this chain.';
            }
            field("PTV Root FG Item No."; Rec."PTV Root FG Item No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the finished-good item at the root of this chain.';
            }
        }
        addfirst(factboxes)
        {
            part(PTVPlanningTrace; "PTV Planning Trace FactBox")
            {
                ApplicationArea = All;
                SubPageLink = "Child Document No." = field("No."), "Child Document Type" = const("Released Prod. Order");
            }
        }
    }

    actions
    {
        addlast(processing)
        {
            action(PTVSuggestRework)
            {
                ApplicationArea = All;
                Caption = 'Suggest Rework';
                Image = CreateDocument;
                ToolTip = 'Creates a rework production order that consumes this batch as the first component.';

                trigger OnAction()
                var
                    ReworkMgt: Codeunit "PTV Rework Mgt";
                begin
                    ReworkMgt.SuggestReworkComponents(Rec);
                end;
            }
            action(PTVMultiLevelTraceability)
            {
                ApplicationArea = All;
                Caption = 'Multi-Level Traceability';
                Image = BOM;
                ToolTip = 'Shows the chain from the root demand forecast through this production order.';

                trigger OnAction()
                var
                    TraceMgt: Codeunit "PTV Planning Trace Mgt";
                begin
                    TraceMgt.OpenTreeForProdOrder(Rec);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        ParentSourceCaption := Rec.PTVParentSourceCaption();
    end;

    var
        ParentSourceCaption: Text[30];
}
