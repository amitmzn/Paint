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
        }
    }
}
