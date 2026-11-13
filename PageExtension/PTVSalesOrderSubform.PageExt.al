pageextension 76102 "PTV Sales Order Subform" extends "Sales Order Subform"
{
    layout
    {
        addlast(Control1)
        {
            field("PTV Product Code"; Rec."PTV Product Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the paint product copied from the item.';
            }
            field("PTV Shade Code"; Rec."PTV Shade Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the shade copied from the item.';
            }
            field("PTV Pack Code"; Rec."PTV Pack Code")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the pack copied from the item.';
            }
            field("PTV Promised Delivery Date"; Rec."PTV Promised Delivery Date")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the promised delivery date for this line.';
            }
            field(PTVQtyLitres; PTVQtyLitres)
            {
                ApplicationArea = All;
                Caption = 'Qty. in Litres';
                DecimalPlaces = 0 : 5;
                Editable = false;
                ToolTip = 'Specifies the line quantity converted to litres.';
            }
            field(PTVQtyKg; PTVQtyKg)
            {
                ApplicationArea = All;
                Caption = 'Qty. in KG';
                DecimalPlaces = 0 : 5;
                Editable = false;
                ToolTip = 'Specifies the line quantity converted to kilograms using specific gravity.';
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        UOMMgt: Codeunit "PTV UOM Mgt";
    begin
        PTVQtyLitres := UOMMgt.LineQuantityToLitres(Rec."No.", Rec."Unit of Measure Code", Rec.Quantity);
        PTVQtyKg := UOMMgt.WeightFromVolume(PTVQtyLitres, UOMMgt.GetSpecificGravity(Rec."No."));
    end;

    var
        PTVQtyLitres: Decimal;
        PTVQtyKg: Decimal;
}
