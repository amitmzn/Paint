page 77068 "PTV Scheme Entitlements"
{
    ApplicationArea = All;
    Caption = 'Scheme Entitlements';
    PageType = List;
    SourceTable = "PTV Scheme Entitlement";
    CardPageId = "PTV Scheme Entitlement Card";
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
                    ToolTip = 'Specifies the entitlement entry number.';
                }
                field("Scheme Code"; Rec."Scheme Code")
                {
                    ToolTip = 'Specifies the scheme code.';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    ToolTip = 'Specifies the customer number.';
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    ToolTip = 'Specifies the customer name.';
                }
                field("Scheme Product Group"; Rec."Scheme Product Group")
                {
                    ToolTip = 'Specifies the scheme product group.';
                }
                field("Period Start Date"; Rec."Period Start Date")
                {
                    ToolTip = 'Specifies the evaluation period start date.';
                }
                field("Period End Date"; Rec."Period End Date")
                {
                    ToolTip = 'Specifies the evaluation period end date.';
                }
                field("Eligible Qty (Kg/Ltr)"; Rec."Eligible Qty (Kg/Ltr)")
                {
                    ToolTip = 'Specifies the eligible quantity in Kg or Litres.';
                }
                field("Net Sales Value"; Rec."Net Sales Value")
                {
                    ToolTip = 'Specifies the eligible net sales value.';
                }
                field("Prior Year Value"; Rec."Prior Year Value")
                {
                    ToolTip = 'Specifies the prior-year comparable net value.';
                }
                field("Growth %"; Rec."Growth %")
                {
                    ToolTip = 'Specifies the YoY growth percentage.';
                }
                field("Growth Qualified"; Rec."Growth Qualified")
                {
                    ToolTip = 'Specifies whether the minimum YoY growth requirement was met.';
                }
                field("Payment Cleared"; Rec."Payment Cleared")
                {
                    ToolTip = 'Specifies whether all required invoices are paid.';
                }
                field("Unpaid Invoice Amount"; Rec."Unpaid Invoice Amount")
                {
                    ToolTip = 'Specifies remaining unpaid amount blocking approval.';
                }
                field("Reward Choice"; Rec."Reward Choice")
                {
                    ToolTip = 'Specifies whether payout is Credit Note, Trip, or FOC Order.';
                }
                field("Total Rebate Amount"; Rec."Total Rebate Amount")
                {
                    ToolTip = 'Specifies the total credit note amount.';
                }
                field("Qualification Tier Code"; Rec."Qualification Tier Code")
                {
                    Editable = false;
                    ToolTip = 'Specifies the qualification tier used to select the reward.';
                }
                field("FOC Reviewed By"; Rec."FOC Reviewed By")
                {
                    Editable = false;
                    ToolTip = 'Specifies who reviewed the FOC entitlement.';
                }
                field("Estimated FOC Cost"; Rec."Estimated FOC Cost")
                {
                    Editable = false;
                    ToolTip = 'Specifies the estimated cost of the FOC reward in local currency.';
                }
                field("FOC Quantity"; Rec."FOC Quantity")
                {
                    ToolTip = 'Specifies the FOC quantity.';
                }
                field("Trip Description"; Rec."Trip Description")
                {
                    ToolTip = 'Specifies the trip option description.';
                }
                field(Status; Rec.Status)
                {
                    ToolTip = 'Specifies the entitlement status.';
                }
                field("Credit Memo No."; Rec."Credit Memo No.")
                {
                    ToolTip = 'Specifies the created sales credit memo number.';
                }
                field("FOC Sales Order No."; Rec."FOC Sales Order No.")
                {
                    ToolTip = 'Specifies the created FOC sales order number.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(RefreshPayment)
            {
                Caption = 'Refresh Payment Status';
                Image = Refresh;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Re-check customer ledger entries for unpaid invoices.';

                trigger OnAction()
                var
                    DocMgt: Codeunit "PTV Scheme Document Mgt";
                begin
                    DocMgt.RefreshPaymentStatus(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(ReviewFOC)
            {
                Caption = 'Review FOC';
                Image = Approve;
                ToolTip = 'Record the cost-of-sales review before a separate user approves the entitlement.';

                trigger OnAction()
                var
                    DocMgt: Codeunit "PTV Scheme Document Mgt";
                begin
                    DocMgt.ReviewFOCEntitlement(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(ApproveAction)
            {
                Caption = 'Approve';
                Image = Approve;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Approve the selected entitlement after verifying growth and payment clearance.';

                trigger OnAction()
                var
                    DocMgt: Codeunit "PTV Scheme Document Mgt";
                begin
                    DocMgt.ApproveEntitlement(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(CreateCreditMemoAction)
            {
                Caption = 'Create Credit Memo';
                Image = CreditMemo;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Create a Sales Credit Memo for the approved entitlement.';

                trigger OnAction()
                var
                    DocMgt: Codeunit "PTV Scheme Document Mgt";
                    CreatedMsg: Label 'Credit Memo %1 created.';
                    DocNo: Code[20];
                begin
                    DocNo := DocMgt.CreateCreditMemo(Rec);
                    Message(CreatedMsg, DocNo);
                    CurrPage.Update(false);
                end;
            }
            action(CreateFOCOrderAction)
            {
                Caption = 'Create FOC Order';
                Image = Order;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Create an FOC Sales Order for the approved entitlement.';

                trigger OnAction()
                var
                    DocMgt: Codeunit "PTV Scheme Document Mgt";
                    CreatedMsg: Label 'FOC Sales Order %1 created.';
                    DocNo: Code[20];
                begin
                    DocNo := DocMgt.CreateFOCSalesOrder(Rec);
                    Message(CreatedMsg, DocNo);
                    CurrPage.Update(false);
                end;
            }
            action(MarkTripFulfilledAction)
            {
                Caption = 'Mark Trip Fulfilled';
                Image = Completed;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Mark the non-monetary trip reward as fulfilled.';

                trigger OnAction()
                var
                    DocMgt: Codeunit "PTV Scheme Document Mgt";
                begin
                    DocMgt.MarkTripFulfilled(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(ViewAppliedEntries)
            {
                Caption = 'Applied Invoice Lines';
                Image = Entries;
                RunObject = page "PTV Scheme Applied Entries";
                RunPageLink = "Entitlement Entry No." = field("Entry No.");
                ToolTip = 'View source invoice and credit memo lines linked to this entitlement.';
            }
        }
    }
}
