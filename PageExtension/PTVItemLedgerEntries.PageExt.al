pageextension 76109 "PTV Item Ledger Entries" extends "Item Ledger Entries"
{
    actions
    {
        addlast(Processing)
        {
            action(PTVInspections)
            {
                ApplicationArea = All;
                Caption = 'Quality Inspections';
                Image = TaskList;
                ToolTip = 'Opens quality inspections for this item and lot.';

                trigger OnAction()
                var
                    QltyInspectionHeader: Record "Qlty. Inspection Header";
                begin
                    QltyInspectionHeader.SetRange("Source Item No.", Rec."Item No.");
                    if Rec."Lot No." <> '' then
                        QltyInspectionHeader.SetRange("Source Lot No.", Rec."Lot No.");
                    Page.Run(Page::"Qlty. Inspection List", QltyInspectionHeader);
                end;
            }
        }
    }
}
