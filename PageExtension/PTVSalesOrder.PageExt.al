pageextension 76103 "PTV Sales Order" extends "Sales Order"
{
    layout
    {
        addlast(General)
        {
            field("PTV Promised Delivery Date"; Rec."PTV Promised Delivery Date")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the date the customer was promised delivery.';
            }
            field("PTV Dispatch Info"; Rec."PTV Dispatch Info")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies dispatch information for this order.';
            }
        }
    }
}
