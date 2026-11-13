page 76077 "PTV Posted Fast Sales"
{
    ApplicationArea = All;
    Caption = 'Posted Fast Sales Invoices';
    Editable = false;
    PageType = List;
    SourceTable = "Sales Invoice Header";
    SourceTableView = where("PTV Fast Sales" = const(true));
    UsageCategory = History;

    layout
    {
        area(Content)
        {
            repeater(Invoices)
            {
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the posted invoice number.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ToolTip = 'Specifies the posting date.';
                }
                field("Sell-to Customer No."; Rec."Sell-to Customer No.")
                {
                    Caption = 'Cash Customer';
                    ToolTip = 'Specifies the cash customer.';
                }
                field("Location Code"; Rec."Location Code")
                {
                    Caption = 'Store';
                    ToolTip = 'Specifies the store location.';
                }
                field("Responsibility Center"; Rec."Responsibility Center")
                {
                    Caption = 'Responsibility Centre';
                    ToolTip = 'Specifies the responsibility centre.';
                }
                field(Amount; Rec.Amount)
                {
                    ToolTip = 'Specifies the invoice amount.';
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        UserSetup: Record "User Setup";
    begin
        if not UserSetup.Get(UserId()) then
            exit;
        if UserSetup."Sales Resp. Ctr. Filter" = '' then
            exit;
        Rec.FilterGroup(2);
        Rec.SetFilter("Responsibility Center", UserSetup."Sales Resp. Ctr. Filter");
        Rec.FilterGroup(0);
    end;
}
