page 77070 "PTV Posted Scheme Entitlements"
{
    ApplicationArea = All;
    Caption = 'Posted Scheme Entitlements';
    PageType = List;
    SourceTable = "PTV Posted Scheme Entitlement";
    UsageCategory = History;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies the posted entitlement entry number.';
                }
                field("Scheme Code"; Rec."Scheme Code")
                {
                    ToolTip = 'Specifies the scheme code.';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ToolTip = 'Specifies the customer number.';
                }
                field("Scheme Product Group"; Rec."Scheme Product Group")
                {
                    ToolTip = 'Specifies the scheme product group.';
                }
                field("Period Start Date"; Rec."Period Start Date")
                {
                    ToolTip = 'Specifies the period start date.';
                }
                field("Period End Date"; Rec."Period End Date")
                {
                    ToolTip = 'Specifies the period end date.';
                }
                field("Eligible Qty (Kg/Ltr)"; Rec."Eligible Qty (Kg/Ltr)")
                {
                    ToolTip = 'Specifies eligible quantity in Kg/Ltr.';
                }
                field("Net Sales Value"; Rec."Net Sales Value")
                {
                    ToolTip = 'Specifies net sales value.';
                }
                field("Growth %"; Rec."Growth %")
                {
                    ToolTip = 'Specifies YoY growth percentage.';
                }
                field("Reward Choice"; Rec."Reward Choice")
                {
                    ToolTip = 'Specifies the reward choice.';
                }
                field("Total Rebate Amount"; Rec."Total Rebate Amount")
                {
                    ToolTip = 'Specifies the total rebate amount.';
                }
                field("Credit Memo No."; Rec."Credit Memo No.")
                {
                    ToolTip = 'Specifies the credit memo number.';
                }
                field("FOC Sales Order No."; Rec."FOC Sales Order No.")
                {
                    ToolTip = 'Specifies the FOC sales order number.';
                }
                field("Posted By"; Rec."Posted By")
                {
                    ToolTip = 'Specifies who posted the entitlement.';
                }
                field("Posted Date"; Rec."Posted Date")
                {
                    ToolTip = 'Specifies when the entitlement was posted.';
                }
            }
        }
    }
}
