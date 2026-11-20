page 77077 "PTV Subsidy Ledger Entries"
{
    ApplicationArea = All;
    Caption = 'Subsidy Ledger Entries';
    Editable = false;
    PageType = List;
    SourceTable = "PTV Subsidy Ledger Entry";
    UsageCategory = History;

    layout
    {
        area(Content)
        {
            repeater(Entries)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the ledger entry number.';
                }
                field("Subsidy Code"; Rec."Subsidy Code")
                {
                    ToolTip = 'Specifies the source subsidy code.';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ToolTip = 'Specifies the customer number.';
                }
                field("Subsidy Type"; Rec."Subsidy Type")
                {
                    ToolTip = 'Specifies the subsidy type.';
                }
                field("Beneficiary Name"; Rec."Beneficiary Name")
                {
                    ToolTip = 'Specifies the beneficiary description.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ToolTip = 'Specifies the credit memo posting date.';
                }
                field(Amount; Rec.Amount)
                {
                    ToolTip = 'Specifies the credited subsidy amount.';
                }
                field("Credit Memo No."; Rec."Credit Memo No.")
                {
                    ToolTip = 'Specifies the generated Sales Credit Memo number.';
                }
            }
        }
    }
}
