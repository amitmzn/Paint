page 50100 "Paint Message"
{
    ApplicationArea = All;
    Caption = 'Paint Message';
    PageType = Card;
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field(Message; MessageTxt)
                {
                    ApplicationArea = All;
                    Caption = 'Message';
                }
            }
        }
    }

    var
        MessageTxt: Text[100];
}
