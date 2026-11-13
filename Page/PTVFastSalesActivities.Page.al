page 76075 "PTV Fast Sales Activities"
{
    ApplicationArea = All;
    Caption = 'Fast Sales Activities';
    PageType = CardPart;
    RefreshOnActivate = true;
    SourceTable = "PTV Fast Sales Cue";

    layout
    {
        area(Content)
        {
            cuegroup(Counter)
            {
                Caption = 'Counter';
                field("Open Invoices"; Rec."Open Invoices")
                {
                    DrillDownPageId = "PTV Fast Sales Invoices";
                    StyleExpr = OpenInvoicesStyle;
                    ToolTip = 'Specifies how many fast sales invoices are still open for your responsibility centre.';
                }
                field("Posted Today"; Rec."Posted Today")
                {
                    DrillDownPageId = "PTV Posted Fast Sales";
                    StyleExpr = PostedTodayStyle;
                    ToolTip = 'Specifies how many fast sales invoices were posted today for your responsibility centre.';
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        UserSetup: Record "User Setup";
    begin
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
        Rec.SetRange("Date Filter", WorkDate());
        if UserSetup.Get(UserId()) and (UserSetup."Sales Resp. Ctr. Filter" <> '') then
            Rec.SetFilter("Resp. Ctr. Filter", UserSetup."Sales Resp. Ctr. Filter");
    end;

    trigger OnAfterGetRecord()
    begin
        if Rec."Open Invoices" = 0 then
            OpenInvoicesStyle := 'Favorable'
        else
            OpenInvoicesStyle := 'Ambiguous';
        if Rec."Posted Today" = 0 then
            PostedTodayStyle := 'Subordinate'
        else
            PostedTodayStyle := 'Favorable';
    end;

    var
        OpenInvoicesStyle: Text;
        PostedTodayStyle: Text;
}
