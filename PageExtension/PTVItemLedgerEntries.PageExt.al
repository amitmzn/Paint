pageextension 76109 "PTV Item Ledger Entries" extends "Item Ledger Entries"
{
    layout
    {
        addafter(Quantity)
        {
            field(PTVQuantityLitres; QuantityLitres)
            {
                ApplicationArea = All;
                Caption = 'Qty. in Litres';
                DecimalPlaces = 0 : 5;
                Editable = false;
                ToolTip = 'Specifies the quantity in litres.';
            }
        }
    }

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

    trigger OnAfterGetRecord()
    var
        UOMMgt: Codeunit "PTV UOM Mgt";
    begin
        QuantityLitres := UOMMgt.PostedLedgerLitres(Rec);
    end;

    var
        QuantityLitres: Decimal;
}
