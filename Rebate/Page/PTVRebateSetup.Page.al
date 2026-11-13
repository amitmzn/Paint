page 77060 "PTV Rebate Setup"
{
    ApplicationArea = All;
    Caption = 'Rebate & Scheme Setup';
    PageType = Card;
    SourceTable = "PTV Rebate Setup";
    UsageCategory = Administration;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'Number Series & Defaults';

                field("Scheme Nos."; Rec."Scheme Nos.")
                {
                    ToolTip = 'Specifies the number series used for rebate schemes.';
                }
                field("Posted Credit Memo Nos."; Rec."Posted Credit Memo Nos.")
                {
                    ToolTip = 'Specifies the default posted credit memo number series for scheme credit notes.';
                }
                field("Default Rebate G/L Account"; Rec."Default Rebate G/L Account")
                {
                    ToolTip = 'Specifies the default G/L account credited/debited on scheme credit memos.';
                }
                field("Default Provision G/L Acc."; Rec."Default Provision G/L Acc.")
                {
                    ToolTip = 'Specifies the default G/L account for rebate provisions.';
                }
                field("Journal Template Name"; Rec."Journal Template Name")
                {
                    ToolTip = 'Specifies the general journal template used for rebate provisions.';
                }
                field("Journal Batch Name"; Rec."Journal Batch Name")
                {
                    ToolTip = 'Specifies the general journal batch used for rebate provisions.';
                }
                field("FOC Reason Code"; Rec."FOC Reason Code")
                {
                    ToolTip = 'Specifies the default reason code stamped on FOC sales orders.';
                }
            }
            group(Controls)
            {
                Caption = 'Policy & Controls';

                field("Auto Detect Special Price"; Rec."Auto Detect Special Price")
                {
                    ToolTip = 'Automatically mark Sales Lines as Special Price when Unit Price is lowered below Item Unit Price.';
                }
                field("Default Payment Gate Mode"; Rec."Default Payment Gate Mode")
                {
                    ToolTip = 'Default payment clearance requirement before credit note approval.';
                }
                field("Suppress VAT on Credit Notes"; Rec."Suppress VAT on Credit Notes")
                {
                    ToolTip = 'Clear VAT posting groups when generating scheme credit memos.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(SeedPDFSchemes)
            {
                Caption = 'Seed 2025 PDF Schemes';
                Image = Setup;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Creates the product groups and template configurations for the April-June 2025 QD Incentive and Summer Bonanza schemes.';

                trigger OnAction()
                var
                    CopySeed: Codeunit "PTV Scheme Copy & Seed";
                    SeededMsg: Label '2025 PDF scheme product groups and templates have been seeded.';
                begin
                    CopySeed.Seed2025PDFSchemes();
                    Message(SeededMsg);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.GetSetup();
    end;
}
