page 76074 "PTV Fast Sales Headline"
{
    Caption = 'Fast Sales Headline';
    PageType = HeadlinePart;
    RefreshOnActivate = true;

    layout
    {
        area(Content)
        {
            group(GreetingGroup)
            {
                ShowCaption = false;
                Visible = GreetingVisible;
                field(GreetingText; RCHeadlinesPageCommon.GetGreetingText())
                {
                    ApplicationArea = All;
                    Caption = 'Greeting';
                    DrillDown = false;
                }
            }
            group(HeadingGroup)
            {
                ShowCaption = false;
                Visible = HeadingVisible;
                field(HeadingText; HeadingText)
                {
                    ApplicationArea = All;
                    Caption = 'Heading';
                }
            }
            group(OpenInvoicesGroup)
            {
                ShowCaption = false;
                Visible = OpenInvoicesVisible;
                field(OpenInvoicesText; OpenInvoicesText)
                {
                    ApplicationArea = All;
                    Caption = 'Open invoices';
                    DrillDown = true;

                    trigger OnDrillDown()
                    begin
                        Page.Run(Page::"PTV Fast Sales Invoices");
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        RCHeadlinesPageCommon.HeadlineOnOpenPage(Page::"PTV Fast Sales Role Center");
        GreetingVisible := RCHeadlinesPageCommon.IsUserGreetingVisible();
        LoadHeading();
        LoadOpenInvoices();
    end;

    var
        RCHeadlinesPageCommon: Codeunit "RC Headlines Page Common";
        HeadingText: Text;
        OpenInvoicesText: Text;
        GreetingVisible: Boolean;
        HeadingVisible: Boolean;
        OpenInvoicesVisible: Boolean;
        DefaultHeadingTxt: Label 'Fast Sales';
        OpenInvoicesLbl: Label '%1 open fast sales invoices', Comment = '%1 = number of open invoices';
        NoOpenInvoicesLbl: Label 'No open fast sales invoices';

    local procedure LoadHeading()
    var
        PaintSetup: Record "PTV Paint Setup";
    begin
        PaintSetup.SetLoadFields("Role Center Heading", "Custom Role Center Heading");
        PaintSetup.GetSetup();
        HeadingVisible := PaintSetup."Role Center Heading" <> PaintSetup."Role Center Heading"::Hidden;
        if not HeadingVisible then
            exit;
        if (PaintSetup."Role Center Heading" = PaintSetup."Role Center Heading"::Custom) and
           (PaintSetup."Custom Role Center Heading" <> '')
        then
            HeadingText := PaintSetup."Custom Role Center Heading"
        else
            HeadingText := DefaultHeadingTxt;
    end;

    local procedure LoadOpenInvoices()
    var
        FastSalesCue: Record "PTV Fast Sales Cue";
        UserSetup: Record "User Setup";
        OpenCount: Integer;
    begin
        if not FastSalesCue.Get() then begin
            FastSalesCue.Init();
            FastSalesCue.Insert();
        end;
        FastSalesCue.SetRange("Date Filter", WorkDate());
        if UserSetup.Get(UserId()) and (UserSetup."Sales Resp. Ctr. Filter" <> '') then
            FastSalesCue.SetFilter("Resp. Ctr. Filter", UserSetup."Sales Resp. Ctr. Filter");
        FastSalesCue.CalcFields("Open Invoices");
        OpenCount := FastSalesCue."Open Invoices";
        OpenInvoicesVisible := true;
        if OpenCount = 0 then
            OpenInvoicesText := NoOpenInvoicesLbl
        else
            OpenInvoicesText := StrSubstNo(OpenInvoicesLbl, OpenCount);
    end;
}
