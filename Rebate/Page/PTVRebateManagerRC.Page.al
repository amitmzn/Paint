page 77079 "PTV Rebate Manager RC"
{
    ApplicationArea = All;
    Caption = 'Rebate & Scheme Manager';
    PageType = RoleCenter;

    layout
    {
        area(RoleCenter)
        {
            part(Activities; "PTV Rebate Cue Part")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(Sections)
        {
            group(SchemesSection)
            {
                Caption = 'Incentive Schemes';

                action(SchemesList)
                {
                    Caption = 'Rebate Schemes';
                    RunObject = page "PTV Scheme List";
                    ToolTip = 'Create, configure, and calculate Trade Quantity and Value Bonus schemes.';
                }
                action(ProductGroups)
                {
                    Caption = 'Scheme Product Groups';
                    RunObject = page "PTV Scheme Product Groups";
                    ToolTip = 'Manage scheme product groups and include/exclude item rules.';
                }
                action(CustomerTargets)
                {
                    Caption = 'Customer Targets & Overrides';
                    RunObject = page "PTV Scheme Customer Targets";
                    ToolTip = 'Manage per-customer baseline and target overrides.';
                }
            }
            group(EntitlementsSection)
            {
                Caption = 'Entitlements & Payouts';

                action(SchemeEntitlements)
                {
                    Caption = 'Scheme Entitlements';
                    RunObject = page "PTV Scheme Entitlements";
                    ToolTip = 'Review, approve, and issue credit notes or FOC orders.';
                }
                action(PostedEntitlements)
                {
                    Caption = 'Posted Entitlements';
                    RunObject = page "PTV Posted Scheme Entitlements";
                    ToolTip = 'View historical posted scheme entitlements and audit trail.';
                }
                action(SalesCreditMemos)
                {
                    Caption = 'Sales Credit Memos';
                    RunObject = page "Sales Credit Memos";
                    ToolTip = 'Review and post generated sales credit memos.';
                }
            }
            group(SubsidiesSection)
            {
                Caption = 'Dealer Subsidies';

                action(SubsidyList)
                {
                    Caption = 'Subsidy Schemes';
                    RunObject = page "PTV Subsidy List";
                    ToolTip = 'Manage monthly dealer subsidies (shop rent, boy salary, transport, display).';
                }
                action(SubsidyLedger)
                {
                    Caption = 'Subsidy Ledger Entries';
                    RunObject = page "PTV Subsidy Ledger Entries";
                    ToolTip = 'View posted subsidy payout ledger entries.';
                }
            }
            group(SetupSection)
            {
                Caption = 'Administration';

                action(RebateSetup)
                {
                    Caption = 'Rebate & Scheme Setup';
                    RunObject = page "PTV Rebate Setup";
                    ToolTip = 'Configure default G/L accounts, credit memo VAT behavior, and payment gate defaults.';
                }
                action(Customers)
                {
                    Caption = 'Customers';
                    RunObject = page "Customer List";
                    ToolTip = 'View and maintain Trade Channel and Tie-Up flags on customers.';
                }
            }
        }
        area(Creation)
        {
            action(NewScheme)
            {
                Caption = 'New Rebate Scheme';
                Image = NewDocument;
                RunObject = page "PTV Scheme Card";
                RunPageMode = Create;
                ToolTip = 'Create a new rebate or incentive scheme.';
            }
            action(NewSubsidy)
            {
                Caption = 'New Subsidy';
                Image = NewDocument;
                RunObject = page "PTV Subsidy Card";
                RunPageMode = Create;
                ToolTip = 'Create a new dealer subsidy sheet.';
            }
        }
        area(Processing)
        {
            action(Seed2025Schemes)
            {
                Caption = 'Seed 2025 PDF Schemes';
                Image = CopyDocument;
                RunObject = codeunit "PTV Scheme Copy & Seed";
                ToolTip = 'Create templates for QD Incentive (018/OBS/2025-26) and Summer Bonanza (019/OBS/2025-26).';
            }
        }
        area(Reporting)
        {
            action(PayoutAnalysis)
            {
                Caption = 'Scheme Payout Analysis';
                Image = Report;
                RunObject = report "PTV Scheme Payout Analysis";
                ToolTip = 'Run the Scheme Payout Analysis report.';
            }
        }
    }
}
