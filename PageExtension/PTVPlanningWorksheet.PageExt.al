pageextension 76350 "PTV Planning Worksheet" extends "Planning Worksheet"
{
    layout
    {
        addafter("Planning Level")
        {
            field("PTV Root Demand Forecast"; Rec."PTV Root Demand Forecast")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the demand forecast that originated this planning chain.';
            }
            field("PTV Root FG Item No."; Rec."PTV Root FG Item No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the finished-good item at the root of this chain.';
            }
            field("PTV Parent Source Type"; Rec."PTV Parent Source Type")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies whether the immediate parent is a demand forecast, planning line, or production order.';
            }
            field(PTVParentSourceCaption; ParentSourceCaption)
            {
                ApplicationArea = All;
                Caption = 'Parent Source No.';
                Editable = false;
                ToolTip = 'Specifies the immediate parent. When this line supplies more than one parent, the value is Multiple (Drill-down).';

                trigger OnDrillDown()
                var
                    TraceMgt: Codeunit "PTV Planning Trace Mgt";
                begin
                    TraceMgt.OpenTreeForRequisitionLine(Rec);
                end;
            }
            field("PTV Parent Source Line No."; Rec."PTV Parent Source Line No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the parent planning line number when the parent is a worksheet line.';
            }
            field("PTV Root FG Prod. Order No."; Rec."PTV Root FG Prod. Order No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the finished-good production order created from the root planning line.';
            }
        }
        addfirst(factboxes)
        {
            part(PTVPlanningTrace; "PTV Planning Trace FactBox")
            {
                ApplicationArea = All;
                SubPageLink = "Child Document Type" = const("Planning Worksheet"), "Child Wksh. Template Name" = field("Worksheet Template Name"), "Child Wksh. Batch Name" = field("Journal Batch Name"), "Child Line No." = field("Line No.");
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
                ToolTip = 'Shows the chain from the root demand forecast through finished goods and semi-finished goods.';

                trigger OnAction()
                var
                    TraceMgt: Codeunit "PTV Planning Trace Mgt";
                begin
                    TraceMgt.OpenTreeForRequisitionLine(Rec);
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
