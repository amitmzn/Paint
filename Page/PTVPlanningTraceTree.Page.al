page 76341 "PTV Planning Trace Tree"
{
    Caption = 'Multi-Level Traceability';
    PageType = List;
    SourceTable = "PTV Planning Trace Node";
    SourceTableTemporary = true;
    ApplicationArea = All;
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                IndentationColumn = Rec.Indentation;
                IndentationControls = "Node Text";

                field("Node Text"; Rec."Node Text")
                {
                    ApplicationArea = All;
                    Style = Strong;
                    ToolTip = 'Specifies the forecast, planning line, or production order at this level.';
                }
                field(Indentation; Rec.Indentation)
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the tree indentation of this node.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the kind of document at this level.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the document number at this level.';
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the line number at this level.';
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the item at this level.';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the item variant at this level.';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the pegged quantity at this level.';
                }
                field("BOM Level"; Rec."BOM Level")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the BOM level.';
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        TraceMgt: Codeunit "PTV Planning Trace Mgt";
    begin
        TraceMgt.BuildTree(Rec, RootForecast, RootItemNo, RootOrderNo);
        if Rec.FindFirst() then;
    end;

    /// <summary>
    /// Selects the forecast and finished good whose chain the tree shows.
    /// </summary>
    procedure SetRoot(ForecastName: Code[20]; ItemNo: Code[20]; OrderNo: Code[20])
    begin
        RootForecast := ForecastName;
        RootItemNo := ItemNo;
        RootOrderNo := OrderNo;
    end;

    var
        RootForecast: Code[20];
        RootItemNo: Code[20];
        RootOrderNo: Code[20];
}
