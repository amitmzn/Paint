page 77076 "PTV Subsidy Lines Subpage"
{
    ApplicationArea = All;
    AutoSplitKey = true;
    Caption = 'Subsidy Lines';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "PTV Subsidy Line";

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Line No."; Rec."Line No.")
                {
                    Visible = false;
                    ToolTip = 'Specifies the line number.';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ToolTip = 'Specifies the dealer customer number.';
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ToolTip = 'Specifies the customer name.';
                }
                field("Subsidy Type"; Rec."Subsidy Type")
                {
                    ToolTip = 'Specifies the subsidy category (Shop Rental, Shop Boy Salary, Transport, Display, Other).';
                }
                field("Beneficiary Name"; Rec."Beneficiary Name")
                {
                    ToolTip = 'Specifies the payee or beneficiary description included on the credit memo.';
                }
                field("Subsidy Amount"; Rec."Subsidy Amount")
                {
                    ToolTip = 'Specifies the fixed subsidy amount granted when qualified.';
                }
                field("Condition Type"; Rec."Condition Type")
                {
                    ToolTip = 'Specifies the sales qualification metric.';
                }
                field("Minimum Value"; Rec."Minimum Value")
                {
                    ToolTip = 'Specifies the minimum sales value or quantity required to qualify.';
                }
                field("Actual Sales Value"; Rec."Actual Sales Value")
                {
                    ToolTip = 'Specifies the net or gross posted sales value achieved in the period.';
                }
                field("Actual Sales Qty (Kg/Ltr)"; Rec."Actual Sales Qty (Kg/Ltr)")
                {
                    ToolTip = 'Specifies the posted sales quantity in Kg/Ltr achieved in the period.';
                }
                field("Sales Qualified"; Rec."Sales Qualified")
                {
                    ToolTip = 'Specifies whether the customer satisfied the condition.';
                }
                field("Entitled Amount"; Rec."Entitled Amount")
                {
                    ToolTip = 'Specifies the calculated subsidy amount.';
                }
                field(Status; Rec.Status)
                {
                    ToolTip = 'Specifies the subsidy line approval and settlement status.';
                }
                field("Credit Memo No."; Rec."Credit Memo No.")
                {
                    ToolTip = 'Specifies the unposted Sales Credit Memo number created for this line.';
                }
            }
        }
    }
}
