page 77069 "PTV Scheme Entitlement Card"
{
    ApplicationArea = All;
    Caption = 'Scheme Entitlement Card';
    PageType = Card;
    SourceTable = "PTV Scheme Entitlement";
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("Entry No."; Rec."Entry No.")
                {
                    Editable = false;
                    ToolTip = 'Specifies the entry number.';
                }
                field("Scheme Code"; Rec."Scheme Code")
                {
                    Editable = false;
                    ToolTip = 'Specifies the scheme code.';
                }
                field("Scheme Description"; Rec."Scheme Description")
                {
                    Editable = false;
                    ToolTip = 'Specifies the scheme description.';
                }
                field("Customer No."; Rec."Customer No.")
                {
                    Editable = false;
                    ToolTip = 'Specifies the customer number.';
                }
                field("Customer Name"; Rec."Customer Name")
                {
                    Editable = false;
                    ToolTip = 'Specifies the customer name.';
                }
                field("Scheme Product Group"; Rec."Scheme Product Group")
                {
                    Editable = false;
                    ToolTip = 'Specifies the scheme product group.';
                }
                field("Period Start Date"; Rec."Period Start Date")
                {
                    Editable = false;
                    ToolTip = 'Specifies the evaluation start date.';
                }
                field("Period End Date"; Rec."Period End Date")
                {
                    Editable = false;
                    ToolTip = 'Specifies the evaluation end date.';
                }
                field(Status; Rec.Status)
                {
                    Editable = false;
                    ToolTip = 'Specifies the status.';
                }
            }
            group(Metrics)
            {
                Caption = 'Sales, Growth & Payment Gate';

                field("Eligible Qty (Kg/Ltr)"; Rec."Eligible Qty (Kg/Ltr)")
                {
                    Editable = false;
                    ToolTip = 'Specifies eligible quantity in Kg/Ltr.';
                }
                field("Net Sales Value"; Rec."Net Sales Value")
                {
                    Editable = false;
                    ToolTip = 'Specifies eligible net sales value.';
                }
                field("Prior Year Qty"; Rec."Prior Year Qty")
                {
                    Editable = false;
                    ToolTip = 'Specifies prior-year quantity.';
                }
                field("Prior Year Value"; Rec."Prior Year Value")
                {
                    Editable = false;
                    ToolTip = 'Specifies prior-year net sales value.';
                }
                field("Growth %"; Rec."Growth %")
                {
                    Editable = false;
                    ToolTip = 'Specifies YoY growth percentage.';
                }
                field("Growth Qualified"; Rec."Growth Qualified")
                {
                    Editable = false;
                    ToolTip = 'Specifies whether YoY growth requirement was met.';
                }
                field("Payment Cleared"; Rec."Payment Cleared")
                {
                    Editable = false;
                    ToolTip = 'Specifies whether all period invoices are paid.';
                }
                field("Unpaid Invoice Amount"; Rec."Unpaid Invoice Amount")
                {
                    Editable = false;
                    ToolTip = 'Specifies remaining unpaid invoice amount.';
                }
            }
            group(Payout)
            {
                Caption = 'Reward & Payout';

                field("Discount Type"; Rec."Discount Type")
                {
                    Editable = false;
                    ToolTip = 'Specifies slab reward type.';
                }
                field("Reward Choice"; Rec."Reward Choice")
                {
                    Editable = CanSelectReward;
                    ToolTip = 'Choose between Credit Note, Trip / Non-Monetary, or FOC Order.';
                }
                field("Rate per Unit"; Rec."Rate per Unit")
                {
                    Editable = false;
                    ToolTip = 'Specifies rate per Kg/Ltr.';
                }
                field("Rebate %"; Rec."Rebate %")
                {
                    Editable = false;
                    ToolTip = 'Specifies rebate percentage.';
                }
                field("Rebate Amount"; Rec."Rebate Amount")
                {
                    Editable = false;
                    ToolTip = 'Specifies base rebate amount.';
                }
                field("Incremental Bonus Amount"; Rec."Incremental Bonus Amount")
                {
                    Editable = false;
                    ToolTip = 'Specifies incremental step bonus amount.';
                }
                field("Total Rebate Amount"; Rec."Total Rebate Amount")
                {
                    Editable = false;
                    ToolTip = 'Specifies total credit note amount.';
                }
                field("Trip Description"; Rec."Trip Description")
                {
                    Editable = false;
                    ToolTip = 'Specifies trip option description.';
                }
                field("FOC Item No."; Rec."FOC Item No.")
                {
                    Editable = false;
                    ToolTip = 'Specifies FOC item.';
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
                    Editable = false;
                    ToolTip = 'Specifies FOC quantity.';
                }
            }
            group(ProductMix)
            {
                Caption = 'Product Mix & References';

                field("Luxury Mix %"; Rec."Luxury Mix %")
                {
                    Editable = false;
                    ToolTip = 'Actual Luxury segment share.';
                }
                field("Premium Mix %"; Rec."Premium Mix %")
                {
                    Editable = false;
                    ToolTip = 'Actual Premium segment share.';
                }
                field("Budget Mix %"; Rec."Budget Mix %")
                {
                    Editable = false;
                    ToolTip = 'Actual Budget & Economy segment share.';
                }
                field("Credit Memo No."; Rec."Credit Memo No.")
                {
                    Editable = false;
                    ToolTip = 'Created sales credit memo number.';
                }
                field("FOC Sales Order No."; Rec."FOC Sales Order No.")
                {
                    Editable = false;
                    ToolTip = 'Created FOC sales order number.';
                }
                field("Rejection Reason"; Rec."Rejection Reason")
                {
                    ToolTip = 'Disqualification or review notes.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
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
                ToolTip = 'Approve the entitlement.';

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
                ToolTip = 'Create a Sales Credit Memo.';

                trigger OnAction()
                var
                    DocMgt: Codeunit "PTV Scheme Document Mgt";
                    CreatedMsg: Label 'Credit Memo %1 created.';
                begin
                    Message(CreatedMsg, DocMgt.CreateCreditMemo(Rec));
                    CurrPage.Update(false);
                end;
            }
        }
    }
    trigger OnAfterGetCurrRecord()
    begin
        CanSelectReward := (Rec.Status in [Rec.Status::Open, Rec.Status::"Pending Approval"]) and
            (Rec."Discount Type" = Rec."Discount Type"::"Trip or Fixed CN");
    end;

    var
        CanSelectReward: Boolean;
}
