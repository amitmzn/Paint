page 77062 "PTV Scheme Card"
{
    ApplicationArea = All;
    Caption = 'Rebate Scheme Card';
    PageType = Document;
    SourceTable = "PTV Scheme Header";

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field(Code; Rec.Code)
                {
                    ToolTip = 'Specifies the scheme code.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the scheme description.';
                }
                field("Reference No."; Rec."Reference No.")
                {
                    ToolTip = 'Specifies the circular or memo reference number.';
                }
                field("Scheme Type"; Rec."Scheme Type")
                {
                    ToolTip = 'Specifies the type of incentive scheme.';
                }
                field("Evaluation Period"; Rec."Evaluation Period")
                {
                    ToolTip = 'Specifies whether performance is evaluated Weekly, Monthly, Quarterly, Annually, or over the Full Period.';
                }
                field("Calculation Basis"; Rec."Calculation Basis")
                {
                    ToolTip = 'Specifies the measurement basis for the scheme.';
                }
                field("Start Date"; Rec."Start Date")
                {
                    ToolTip = 'Specifies the scheme start date.';
                }
                field("End Date"; Rec."End Date")
                {
                    ToolTip = 'Specifies the scheme end date.';
                }
                field(Status; Rec.Status)
                {
                    Editable = false;
                    ToolTip = 'Specifies the lifecycle status of the scheme.';
                }
            }
            group(Eligibility)
            {
                Caption = 'Applicability & Filters';

                field("Trade Channel Filter"; Rec."Trade Channel Filter")
                {
                    ToolTip = 'Restrict scheme to a specific trade channel (e.g. Trade).';
                }
                field("Territory Filter"; Rec."Territory Filter")
                {
                    ToolTip = 'Restrict scheme to matching customer territories.';
                }
                field("Location Filter"; Rec."Location Filter")
                {
                    ToolTip = 'Restrict scheme to matching depot/location codes.';
                }
                field("Cust. Price Group Filter"; Rec."Cust. Price Group Filter")
                {
                    ToolTip = 'Restrict scheme to matching customer price groups.';
                }
                field("Customer Filter"; Rec."Customer Filter")
                {
                    ToolTip = 'Restrict scheme to specific customers.';
                }
                field("Exclusion Group"; Rec."Exclusion Group")
                {
                    ToolTip = 'Schemes sharing an Exclusion Group cannot claim the same invoice lines.';
                }
            }
            group(QualRules)
            {
                Caption = 'Growth, Payment & Exclusions';

                field("Minimum Net Value"; Rec."Minimum Net Value")
                {
                    ToolTip = 'Specifies the minimum eligible net sales value required.';
                }
                field("Minimum Quantity"; Rec."Minimum Quantity")
                {
                    ToolTip = 'Specifies the minimum eligible quantity required.';
                }
                field("Exclude FOC Lines"; Rec."Exclude FOC Lines")
                {
                    ToolTip = 'Exclude FOC sales lines from scheme accumulation.';
                }
                field("Special Price Handling"; Rec."Special Price Handling")
                {
                    ToolTip = 'Specifies how tie-up discounts and special prices are handled.';
                }
                field("Require Growth Check"; Rec."Require Growth Check")
                {
                    ToolTip = 'Require year-over-year growth over the corresponding prior-year period.';
                }
                field("Default Min Growth %"; Rec."Default Min Growth %")
                {
                    ToolTip = 'Specifies the default minimum YoY growth percentage.';
                }
                field("Growth Failure Action"; Rec."Growth Failure Action")
                {
                    ToolTip = 'Specifies whether failing growth disqualifies or steps down to a lower slab.';
                }
                field("Payment Gate Mode"; Rec."Payment Gate Mode")
                {
                    ToolTip = 'Specifies whether open customer invoices block entitlement approval.';
                }
            }
            group(MixAndPosting)
            {
                Caption = 'Product Mix & Posting';

                field("Enforce Product Mix"; Rec."Enforce Product Mix")
                {
                    ToolTip = 'Block approval if customer mix falls below target segment percentages.';
                }
                field("Luxury Mix Target %"; Rec."Luxury Mix Target %")
                {
                    ToolTip = 'Target Luxury segment percentage.';
                }
                field("Premium Mix Target %"; Rec."Premium Mix Target %")
                {
                    ToolTip = 'Target Premium segment percentage.';
                }
                field("Budget Mix Target %"; Rec."Budget Mix Target %")
                {
                    ToolTip = 'Target Budget & Economy segment percentage.';
                }
                field("Rebate G/L Account"; Rec."Rebate G/L Account")
                {
                    ToolTip = 'Specifies the G/L account used on scheme credit memos.';
                }
                field("Suppress VAT on Credit Notes"; Rec."Suppress VAT on Credit Notes")
                {
                    ToolTip = 'Use the configured zero VAT posting groups on generated credit memos.';
                }
                field("Use Customer Targets"; Rec."Use Customer Targets")
                {
                    ToolTip = 'Specifies the use customer targets.';
                }
                field("Exclude If No Target"; Rec."Exclude If No Target")
                {
                    ToolTip = 'Specifies the exclude if no target.';
                }
                field("Default Target Value"; Rec."Default Target Value")
                {
                    ToolTip = 'Specifies the default target value.';
                }
                field("Payment Cutoff Date"; Rec."Payment Cutoff Date")
                {
                    ToolTip = 'Specifies the payment cutoff date.';
                }
                field("Claim Priority"; Rec."Claim Priority")
                {
                    ToolTip = 'Specifies the claim priority.';
                }
                field("Require FOC Review"; Rec."Require FOC Review")
                {
                    ToolTip = 'Specifies the require foc review.';
                }
                field("Suppress VAT on FOC"; Rec."Suppress VAT on FOC")
                {
                    ToolTip = 'Specifies the suppress vat on foc.';
                }
                field("FOC Reason Code"; Rec."FOC Reason Code")
                {
                    ToolTip = 'Specifies the reason code applied to FOC sales orders.';
                }
                field("Posted Credit Memo Nos."; Rec."Posted Credit Memo Nos.")
                {
                    ToolTip = 'Specifies the posted credit memo number series.';
                }
            }
            part(Lines; "PTV Scheme Lines Subpage")
            {
                Caption = 'Scheme Lines (Product Groups / Exclusions)';
                SubPageLink = "Scheme Code" = field(Code);
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ReleaseScheme)
            {
                Caption = 'Release';
                Image = ReleaseDoc;
                Promoted = true;
                PromotedCategory = Process;
                Enabled = Rec.Status = Rec.Status::Open;
                ToolTip = 'Release the scheme for calculation.';

                trigger OnAction()
                begin
                    Rec.TestField("Start Date");
                    Rec.TestField("End Date");
                    ValidateSlabsForRelease();
                    Rec.Status := Rec.Status::Released;
                    Rec.Modify(true);
                end;
            }
            action(ReopenScheme)
            {
                Caption = 'Reopen';
                Image = ReOpen;
                Promoted = true;
                PromotedCategory = Process;
                Enabled = Rec.Status = Rec.Status::Released;
                ToolTip = 'Reopen the scheme for editing.';

                trigger OnAction()
                begin
                    Rec.Status := Rec.Status::Open;
                    Rec.Modify(true);
                end;
            }
            action(CalculateScheme)
            {
                Caption = 'Calculate Entitlements';
                Image = Calculate;
                Promoted = true;
                PromotedCategory = Process;
                Enabled = Rec.Status = Rec.Status::Released;
                ToolTip = 'Calculate customer entitlements across periods. When an exclusion group is set, released schemes in the group run in claim priority order.';

                trigger OnAction()
                var
                    CalcEngine: Codeunit "PTV Scheme Calc Engine";
                    CalcDoneMsg: Label 'Calculation complete. %1 entitlement(s) created.';
                    CreatedCount: Integer;
                begin
                    CreatedCount := CalcEngine.CalculateScheme(Rec);
                    Message(CalcDoneMsg, CreatedCount);
                end;
            }
            action(CalculatePriorityGroup)
            {
                Caption = 'Calculate Exclusion Group';
                Image = Calculate;
                ToolTip = 'Recalculates released schemes in this exclusion group in priority order. Lower numbers claim sales first.';

                trigger OnAction()
                var
                    CalcEngine: Codeunit "PTV Scheme Calc Engine";
                    CalculatedMsg: Label '%1 entitlements calculated.', Comment = '%1 = entitlement count';
                begin
                    Rec.TestField("Exclusion Group");
                    Message(CalculatedMsg, CalcEngine.CalculateExclusionGroup(Rec."Exclusion Group"));
                end;
            }
            action(OpenHeaderSlabs)
            {
                Caption = 'Value / Header Slabs';
                Image = Discount;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Open slabs attached at the whole-scheme level (Line No. = 0).';

                trigger OnAction()
                var
                    Slab: Record "PTV Scheme Slab";
                begin
                    Slab.SetRange("Scheme Code", Rec.Code);
                    Slab.SetRange("Scheme Line No.", 0);
                    Page.RunModal(Page::"PTV Scheme Slabs", Slab);
                end;
            }
            action(OpenEntitlements)
            {
                Caption = 'Entitlements';
                Image = Entries;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = page "PTV Scheme Entitlements";
                RunPageLink = "Scheme Code" = field(Code);
                ToolTip = 'View calculated entitlements for this scheme.';
            }
            action(PostAndClose)
            {
                Caption = 'Post & Close Scheme';
                Image = PostDocument;
                Promoted = true;
                PromotedCategory = Process;
                Enabled = Rec.Status = Rec.Status::Released;
                ToolTip = 'Post finalized entitlements to Posted Scheme Entitlements and close the scheme.';

                trigger OnAction()
                var
                    PostMgt: Codeunit "PTV Scheme Entitlement Post";
                    PostedMsg: Label 'Posted %1 entitlement(s) and closed scheme %2.';
                    PostedCount: Integer;
                begin
                    PostedCount := PostMgt.PostEntitlements(Rec.Code, true);
                    Message(PostedMsg, PostedCount, Rec.Code);
                end;
            }
            action(ArchiveSettledEntitlements)
            {
                Caption = 'Archive Settled Entitlements';
                ToolTip = 'Archives settled entitlements and leaves the scheme open for remaining payouts.';

                trigger OnAction()
                var
                    PostMgt: Codeunit "PTV Scheme Entitlement Post";
                    ArchivedMsg: Label '%1 entitlements archived.', Comment = '%1 = entitlement count';
                begin
                    Message(ArchivedMsg, PostMgt.PostEntitlements(Rec.Code, false));
                    CurrPage.Update(false);
                end;
            }
            action(CopySchemeAction)
            {
                Caption = 'Copy Scheme';
                Image = Copy;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Create a new Open copy of this scheme.';

                trigger OnAction()
                var
                    CopySeed: Codeunit "PTV Scheme Copy & Seed";
                    CopiedMsg: Label 'Scheme %1 copied to a new Open scheme.';
                begin
                    CopySeed.CopyScheme(Rec.Code, '');
                    Message(CopiedMsg, Rec.Code);
                end;
            }
        }
    }
    local procedure ValidateSlabsForRelease()
    var
        Engine: Codeunit "PTV Scheme Calc Engine";
    begin
        Engine.ValidateSchemeSlabs(Rec);
    end;
}
