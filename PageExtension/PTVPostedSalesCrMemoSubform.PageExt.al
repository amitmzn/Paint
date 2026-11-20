pageextension 76112 "PTV Posted Sales Cr. Subform" extends "Posted Sales Cr. Memo Subform"
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
            QuantityLitres := UOMMgt.PostedCreditMemoLitres(Rec);
    end;

    var
        QuantityLitres: Decimal;
}
