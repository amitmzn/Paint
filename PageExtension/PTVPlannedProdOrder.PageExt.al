pageextension 76351 "PTV Planned Prod. Order" extends "Planned Production Order"
{
    layout
    {
        addlast(General)
        {
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
                SubPageLink = "Child Document No." = field("No."), "Child Document Type" = const("Planned Prod. Order");
            }
        }
    }

    actions
    {
        addlast(processing)
        {
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
