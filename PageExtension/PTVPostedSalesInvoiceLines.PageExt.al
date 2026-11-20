pageextension 76114 "PTV Posted Sales Invoice Lines" extends "Posted Sales Invoice Lines"
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
            QuantityLitres := UOMMgt.PostedInvoiceLitres(Rec);
    end;

    var
        QuantityLitres: Decimal;
}
