page 77075 "PTV Subsidy Card"
{
    ApplicationArea = All;
    Caption = 'Subsidy Card';
    PageType = Document;
    SourceTable = "PTV Subsidy Header";

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field(Code; Rec.Code)
                {
                    ToolTip = 'Specifies the subsidy code.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the subsidy description.';
                }
                field("Period Month"; Rec."Period Month")
                {
                    ToolTip = 'Specifies the subsidy month (1-12). Setting month and year fills Start Date and End Date.';
                }
                field("Period Year"; Rec."Period Year")
                {
                    ToolTip = 'Specifies the subsidy year.';
                }
                field("Start Date"; Rec."Start Date")
                {
                    ToolTip = 'Specifies the evaluation start date.';
                }
                field("End Date"; Rec."End Date")
                {
                    ToolTip = 'Specifies the evaluation end date.';
                }
                field("Territory Filter"; Rec."Territory Filter")
                {
                    ToolTip = 'Specifies eligible territory codes (e.g. KA|GA).';
                }
                field("Location Filter"; Rec."Location Filter")
                {
                    ToolTip = 'Specifies eligible depot/location codes.';
                }
                field("Rebate G/L Account"; Rec."Rebate G/L Account")
                {
                    ToolTip = 'Specifies the G/L account used when creating subsidy credit memos.';
                }
                field(Status; Rec.Status)
                {
                    Editable = false;
                    ToolTip = 'Specifies the subsidy lifecycle status.';
                }
            }
            part(Lines; "PTV Subsidy Lines Subpage")
            {
                Caption = 'Subsidy Lines';
                SubPageLink = "Subsidy Code" = field(Code);
                UpdatePropagation = Both;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Release)
            {
                Caption = 'Release';
                Image = ReleaseDoc;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Release the subsidy so entitlements can be calculated.';

                trigger OnAction()
                var
                    SubsidyMgt: Codeunit "PTV Subsidy Mgt";
                begin
                    SubsidyMgt.ReleaseSubsidy(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(Reopen)
            {
                Caption = 'Reopen';
                Image = ReOpen;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Reopen the subsidy for editing.';

                trigger OnAction()
                var
                    SubsidyMgt: Codeunit "PTV Subsidy Mgt";
                begin
                    SubsidyMgt.ReopenSubsidy(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(CalculateEntitlements)
            {
                Caption = 'Calculate Qualified Sales';
                Image = Calculate;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Evaluate customer sales against each line condition and compute entitled subsidy amounts.';

                trigger OnAction()
                var
                    SubsidyMgt: Codeunit "PTV Subsidy Mgt";
                    CalculatedMsg: Label 'Subsidy qualification calculated for %1.';
                begin
                    SubsidyMgt.CalculateEntitlements(Rec);
                    CurrPage.Update(false);
                    Message(CalculatedMsg, Rec.Code);
                end;
            }
            action(ApproveLines)
            {
                Caption = 'Approve Qualified Lines';
                Image = Approve;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Approve all qualified open subsidy lines with positive entitled amount.';

                trigger OnAction()
                var
                    SubsidyMgt: Codeunit "PTV Subsidy Mgt";
                    ApprovedCount: Integer;
                    ApprovedMsg: Label '%1 qualified subsidy line(s) approved.';
                begin
                    ApprovedCount := SubsidyMgt.ApproveQualifiedLines(Rec.Code);
                    CurrPage.Update(false);
                    Message(ApprovedMsg, ApprovedCount);
                end;
            }
            action(CreateCreditMemos)
            {
                Caption = 'Create Credit Memos';
                Image = CreditMemo;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Generate Sales Credit Memos and Subsidy Ledger Entries for approved lines.';

                trigger OnAction()
                var
                    SubsidyMgt: Codeunit "PTV Subsidy Mgt";
                    CreatedCount: Integer;
                    CreatedMsg: Label '%1 subsidy credit memo(s) created.';
                begin
                    CreatedCount := SubsidyMgt.CreateCreditMemos(Rec.Code);
                    CurrPage.Update(false);
                    Message(CreatedMsg, CreatedCount);
                end;
            }
            action(CloseSubsidy)
            {
                Caption = 'Post & Close';
                Image = Close;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Mark credit-note-created lines as Posted and close the subsidy.';

                trigger OnAction()
                var
                    SubsidyMgt: Codeunit "PTV Subsidy Mgt";
                begin
                    SubsidyMgt.CloseSubsidy(Rec);
                    CurrPage.Update(false);
                end;
            }
        }
        area(Navigation)
        {
            action(LedgerEntries)
            {
                Caption = 'Subsidy Ledger Entries';
                Image = LedgerEntries;
                RunObject = page "PTV Subsidy Ledger Entries";
                RunPageLink = "Subsidy Code" = field(Code);
                ToolTip = 'View posted subsidy credit memo ledger entries for this subsidy.';
            }
        }
    }
}
