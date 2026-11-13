page 77078 "PTV Rebate Cue Part"
{
    ApplicationArea = All;
    Caption = 'Rebate & Scheme Activities';
    PageType = CardPart;
    SourceTable = "PTV Rebate Cue";

    layout
    {
        area(Content)
        {
            cuegroup(Schemes)
            {
                Caption = 'Schemes';

                field("Open Schemes"; Rec."Open Schemes")
                {
                    DrillDownPageId = "PTV Scheme List";
                    ToolTip = 'Number of schemes in Open status.';
                }
                field("Released Schemes"; Rec."Released Schemes")
                {
                    DrillDownPageId = "PTV Scheme List";
                    ToolTip = 'Number of active Released schemes.';
                }
                field("Open Subsidies"; Rec."Open Subsidies")
                {
                    DrillDownPageId = "PTV Subsidy List";
                    ToolTip = 'Number of subsidies in Open status.';
                }
            }
            cuegroup(Entitlements)
            {
                Caption = 'Entitlements';

                field("Open Entitlements"; Rec."Open Entitlements")
                {
                    DrillDownPageId = "PTV Scheme Entitlements";
                    ToolTip = 'Number of calculated entitlements awaiting approval.';
                }
                field("Approved Entitlements"; Rec."Approved Entitlements")
                {
                    DrillDownPageId = "PTV Scheme Entitlements";
                    ToolTip = 'Number of approved entitlements ready for Credit Memo or FOC Order.';
                }
                field("Posted Entitlements"; Rec."Posted Entitlements")
                {
                    DrillDownPageId = "PTV Posted Scheme Entitlements";
                    ToolTip = 'Total historical posted scheme entitlements.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;
}
