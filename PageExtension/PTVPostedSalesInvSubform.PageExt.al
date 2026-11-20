pageextension 76104 "PTV Posted Sales Inv. Subform" extends "Posted Sales Invoice Subform"
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
        addlast(Control1)
        {
            field("PTV Product Code"; Rec."PTV Product Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the paint product posted with this line.';
            }
            field("PTV Shade Code"; Rec."PTV Shade Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the shade posted with this line.';
            }
            field("PTV Pack Code"; Rec."PTV Pack Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the pack posted with this line.';
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
