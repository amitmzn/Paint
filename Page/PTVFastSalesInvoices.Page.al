page 76073 "PTV Fast Sales Invoices"
{
    ApplicationArea = All;
    Caption = 'Counter Sales Invoices';
    CardPageId = "PTV Fast Sales Invoice";
    Editable = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "Sales Header";
    SourceTableView = where("Document Type" = const(Invoice), "PTV Fast Sales" = const(true));
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(Invoices)
            {
                field("No."; Rec."No.")
                {
                    ToolTip = 'Specifies the sales invoice number.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ToolTip = 'Specifies the posting date.';
                }
                field("PTV Customer Type"; Rec."PTV Customer Type")
                {
                    ApplicationArea = All;
                    Caption = 'Customer Type';
                    ToolTip = 'Specifies whether this is a cash sale or a credit customer sale.';
                }
                field("Sell-to Customer No."; Rec."Sell-to Customer No.")
                {
                    Caption = 'Customer No.';
                    ToolTip = 'Specifies the customer number.';
                }
                field("Sell-to Customer Name"; Rec."Sell-to Customer Name")
                {
                    Caption = 'Customer Name';
                    ToolTip = 'Specifies the customer name.';
                }
                field("PTV Mobile No."; Rec."PTV Mobile No.")
                {
                    ApplicationArea = All;
                    Caption = 'Mobile No.';
                    ToolTip = 'Specifies the customer mobile phone number.';
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
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(NewInvoice)
            {
                ApplicationArea = All;
                Caption = 'New';
                Image = New;
                ToolTip = 'Create a counter sales invoice and select the cash customer for your store.';

                trigger OnAction()
                var
                    SalesHeader: Record "Sales Header";
                    FastSalesMgt: Codeunit "PTV Fast Sales Mgt";
                begin
                    FastSalesMgt.CreateInvoice(SalesHeader);
                    SalesHeader.SetRecFilter();
                    Page.Run(Page::"PTV Fast Sales Invoice", SalesHeader);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';
                actionref(NewInvoice_Promoted; NewInvoice) { }
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
