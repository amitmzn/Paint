pageextension 76111 "PTV Sales Invoice Subform" extends "Sales Invoice Subform"
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

    trigger OnAfterGetRecord()
    var
        UOMMgt: Codeunit "PTV UOM Mgt";
    begin
        Clear(QuantityLitres);
        if Rec.Type = Rec.Type::Item then
            QuantityLitres := UOMMgt.TransactionLitres(Rec."Unit of Measure Code", Rec.Quantity, Rec."Quantity (Base)", UOMMgt.LitresPerBaseUnit(Rec."No."));
    end;

    var
        QuantityLitres: Decimal;
}
