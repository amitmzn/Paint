page 77071 "PTV Scheme Applied Entries"
{
    ApplicationArea = All;
    Caption = 'Scheme Applied Entries';
    PageType = List;
    SourceTable = "PTV Scheme Applied Entry";
    UsageCategory = Lists;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the entry number.';
                }
                field("Scheme Code"; Rec."Scheme Code")
                {
                    ToolTip = 'Specifies the scheme code.';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ToolTip = 'Specifies the customer number.';
                }
                field("Source Document Type"; Rec."Source Document Type")
                {
                    ToolTip = 'Specifies the document type.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ToolTip = 'Specifies the document number.';
                }
                field("Document Line No."; Rec."Document Line No.")
                {
                    ToolTip = 'Specifies the document line number.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ToolTip = 'Specifies the posting date.';
                }
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies the item number.';
                }
                field(Quantity; Rec.Quantity)
                {
                    ToolTip = 'Specifies the document line quantity.';
                }
                field("Eligible Qty (Kg/Ltr)"; Rec."Eligible Qty (Kg/Ltr)")
                {
                    ToolTip = 'Specifies the measured quantity in Kg/Ltr.';
                }
                field("Net Amount"; Rec."Net Amount")
                {
                    ToolTip = 'Specifies the net line amount.';
                }
            }
        }
    }
}
