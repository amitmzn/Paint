pageextension 77104 "PTV Rebate Paint Role Center" extends "PTV Paint Role Center"
{
    actions
    {
        addlast(Sections)
        {
            group(DealerIncentives)
            {
                Caption = 'Dealer Incentives';

                action(RebateSchemes)
                {
                    ApplicationArea = All;
                    Caption = 'Rebate Schemes';
                    RunObject = page "PTV Scheme List";
                    ToolTip = 'Open dealer rebate and incentive schemes.';
                }

                action(SchemeEntitlements)
                {
                    ApplicationArea = All;
                    Caption = 'Scheme Entitlements';
                    RunObject = page "PTV Scheme Entitlements";
                    ToolTip = 'Review dealer scheme entitlements.';
                }

                action(PostedSchemeEntitlements)
                {
                    ApplicationArea = All;
                    Caption = 'Posted Scheme Entitlements';
                    RunObject = page "PTV Posted Scheme Entitlements";
                    ToolTip = 'Review archived dealer entitlements.';
                }

                action(SchemeGroups)
                {
                    ApplicationArea = All;
                    Caption = 'Scheme Product Groups';
                    RunObject = page "PTV Scheme Product Groups";
                    ToolTip = 'Manage the product groups used in dealer schemes.';
                }

                action(SchemeTiers)
                {
                    ApplicationArea = All;
                    Caption = 'Qualification Tiers';
                    RunObject = page "PTV Qualification Tiers";
                    ToolTip = 'Open the scheme qualification tiers.';
                }

                action(SchemeTargets)
                {
                    ApplicationArea = All;
                    Caption = 'Customer Targets';
                    RunObject = page "PTV Scheme Customer Targets";
                    ToolTip = 'Open the scheme customer targets.';
                }

                action(DealerSubsidies)
                {
                    ApplicationArea = All;
                    Caption = 'Dealer Subsidies';
                    RunObject = page "PTV Subsidy List";
                    ToolTip = 'Open dealer subsidy schemes.';
                }

                action(SubsidyLedger)
                {
                    ApplicationArea = All;
                    Caption = 'Subsidy Ledger Entries';
                    RunObject = page "PTV Subsidy Ledger Entries";
                    ToolTip = 'Review subsidy payout entries.';
                }

                action(RebateSetup)
                {
                    ApplicationArea = All;
                    Caption = 'Rebate Setup';
                    RunObject = page "PTV Rebate Setup";
                    ToolTip = 'Configure the dealer incentives module.';
                }
            }
        }
        addlast(Reporting)
        {
            action(SchemePayoutAnalysis)
            {
                ApplicationArea = All;
                Caption = 'Scheme Payout Analysis';
                Image = Report;
                RunObject = report "PTV Scheme Payout Analysis";
                ToolTip = 'Open the scheme payout analysis report.';
            }
        }
    }
}
