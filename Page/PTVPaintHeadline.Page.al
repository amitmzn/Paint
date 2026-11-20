page 76079 "PTV Paint Headline"
{
    ApplicationArea = All;
    Caption = 'Paint Vertical Headline';
    PageType = HeadlinePart;

    layout
    {
        area(Content)
        {
            field(Greeting; Headlines.GetGreetingText())
            {
                ApplicationArea = All;
                DrillDown = false;
                Visible = ShowGreeting;
            }
            field(DailyWork; DailyWorkTxt)
            {
                ApplicationArea = All;
                DrillDown = false;
            }
        }
    }

    trigger OnOpenPage()
    begin
        Headlines.HeadlineOnOpenPage(Page::"PTV Paint Role Center");
        ShowGreeting := Headlines.IsUserGreetingVisible();
    end;

    var
        Headlines: Codeunit "RC Headlines Page Common";
        ShowGreeting: Boolean;
        DailyWorkTxt: Label '<qualifier>Daily Work</qualifier><payload>Manage paint batches, inspections, and sales</payload>', Comment = 'Translate the text and retain the qualifier and payload tags.';
}
