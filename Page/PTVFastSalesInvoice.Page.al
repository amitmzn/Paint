page 76071 "PTV Fast Sales Invoice"
{
    ApplicationArea = All;
    Caption = 'Counter Sales Invoice';
    PageType = Document;
    SourceTable = "Sales Header";
    SourceTableView = where("Document Type" = const(Invoice), "PTV Fast Sales" = const(true));
    UsageCategory = Documents;
    RefreshOnActivate = true;
    InsertAllowed = false;
    AdditionalSearchTerms = 'POS,Cash Sale,Counter Sales';

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
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

                    trigger OnValidate()
                    var
                        FastSalesMgt: Codeunit "PTV Fast Sales Mgt";
                        DefaultCashCust: Code[20];
                        CreditNotAllowedErr: Label 'Store %1 does not allow credit sales.', Comment = '%1 = store code';
                    begin
                        if Rec."PTV Customer Type" = Rec."PTV Customer Type"::Credit then begin
                            if not FastSalesMgt.IsCreditSalesAllowed(Rec."Location Code") then
                                Error(CreditNotAllowedErr, Rec."Location Code");
                            DefaultCashCust := FastSalesMgt.GetDefaultCashCustomer(Rec."Location Code");
                            if (DefaultCashCust <> '') and (Rec."Sell-to Customer No." = DefaultCashCust) then begin
                                Rec.Validate("Sell-to Customer No.", '');
                                Rec."PTV Mobile No." := '';
                            end;
                        end else begin
                            DefaultCashCust := FastSalesMgt.GetDefaultCashCustomer(Rec."Location Code");
                            if DefaultCashCust <> '' then
                                Rec.Validate("Sell-to Customer No.", DefaultCashCust);
                        end;
                        CurrPage.Update(true);
                    end;
                }
                field("Sell-to Customer No."; Rec."Sell-to Customer No.")
                {
                    Caption = 'Customer No.';
                    ToolTip = 'Specifies the customer. For cash sales, selects the store cash customer. For credit sales, select the registered customer.';

                    trigger OnValidate()
                    var
                        Customer: Record Customer;
                        FastSalesMgt: Codeunit "PTV Fast Sales Mgt";
                        DefaultCashCust: Code[20];
                        CreditNotAllowedErr: Label 'Store %1 does not allow credit sales.', Comment = '%1 = store code';
                    begin
                        DefaultCashCust := FastSalesMgt.GetDefaultCashCustomer(Rec."Location Code");
                        if Rec."Sell-to Customer No." <> '' then begin
                            if (DefaultCashCust <> '') and (Rec."Sell-to Customer No." = DefaultCashCust) then
                                Rec."PTV Customer Type" := Rec."PTV Customer Type"::Cash
                            else begin
                                if not FastSalesMgt.IsCreditSalesAllowed(Rec."Location Code") then
                                    Error(CreditNotAllowedErr, Rec."Location Code");
                                Rec."PTV Customer Type" := Rec."PTV Customer Type"::Credit;
                            end;
                            if Customer.Get(Rec."Sell-to Customer No.") then begin
                                if Customer."Mobile Phone No." <> '' then
                                    Rec."PTV Mobile No." := Customer."Mobile Phone No."
                                else if (Customer."Phone No." <> '') and (Rec."PTV Customer Type" = Rec."PTV Customer Type"::Credit) then
                                    Rec."PTV Mobile No." := Customer."Phone No.";
                            end;
                        end else
                            Rec."PTV Mobile No." := '';
                        CurrPage.Update(true);
                    end;
                }
                field("Sell-to Customer Name"; Rec."Sell-to Customer Name")
                {
                    Caption = 'Customer Name';
                    ToolTip = 'Specifies the name of the customer.';
                }
                field("PTV Mobile No."; Rec."PTV Mobile No.")
                {
                    ApplicationArea = All;
                    Caption = 'Mobile No.';
                    ToolTip = 'Specifies the customer mobile phone number. For credit customers it defaults from the customer card; for cash sales it can be entered directly.';
                }
                field("Location Code"; Rec."Location Code")
                {
                    Caption = 'Store';
                    ToolTip = 'Specifies the store location.';

                    trigger OnValidate()
                    var
                        FastSalesMgt: Codeunit "PTV Fast Sales Mgt";
                        DefaultCashCust: Code[20];
                    begin
                        if Rec."PTV Customer Type" = Rec."PTV Customer Type"::Cash then begin
                            DefaultCashCust := FastSalesMgt.GetDefaultCashCustomer(Rec."Location Code");
                            if (DefaultCashCust <> '') and (Rec."Sell-to Customer No." <> DefaultCashCust) then
                                Rec.Validate("Sell-to Customer No.", DefaultCashCust);
                        end;
                        CurrPage.Update(true);
                    end;
                }
                field("Responsibility Center"; Rec."Responsibility Center")
                {
                    Caption = 'Responsibility Centre';
                    ToolTip = 'Specifies the responsibility centre for this invoice.';
                }
            }
            part(SalesLines; "PTV Fast Sales Inv. Subform")
            {
                ApplicationArea = All;
                SubPageLink = "Document Type" = field("Document Type"), "Document No." = field("No.");
                UpdatePropagation = Both;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(PostInvoice)
            {
                ApplicationArea = All;
                Caption = 'Post';
                Image = Post;
                ShortCutKey = 'F9';
                ToolTip = 'Post the sales invoice.';

                trigger OnAction()
                begin
                    PostCurrentInvoice(false);
                end;
            }
            action(PostAndNew)
            {
                ApplicationArea = All;
                Caption = 'Post and New';
                Image = PostOrder;
                ShortCutKey = 'Shift+F9';
                ToolTip = 'Post this sales invoice and open a new one for the same store.';

                trigger OnAction()
                begin
                    PostCurrentInvoice(true);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';
                actionref(PostInvoice_Promoted; PostInvoice) { }
                actionref(PostAndNew_Promoted; PostAndNew) { }
            }
        }
    }

    trigger OnOpenPage()
    var
        SalesHeader: Record "Sales Header";
        FastSalesMgt: Codeunit "PTV Fast Sales Mgt";
    begin
        if IsOpenedOnExistingInvoice() then
            exit;
        FastSalesMgt.CreateInvoice(SalesHeader);
        Rec.FilterGroup(2);
        Rec.SetRange("Document Type", SalesHeader."Document Type");
        Rec.SetRange("No.", SalesHeader."No.");
        Rec.FilterGroup(0);
        Rec.Get(SalesHeader."Document Type", SalesHeader."No.");
    end;

    local procedure PostCurrentInvoice(OpenNew: Boolean)
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        FastSalesMgt: Codeunit "PTV Fast Sales Mgt";
        NothingToPostErr: Label 'Enter a quantity before posting.';
        PostInvoiceQst: Label 'Post invoice %1?', Comment = '%1 = invoice number';
        CustomerMissingErr: Label 'Select a customer before posting.';
    begin
        CurrPage.SaveRecord();
        SalesHeader.Get(Rec."Document Type", Rec."No.");
        if SalesHeader."Sell-to Customer No." = '' then
            Error(CustomerMissingErr);
        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetFilter(Quantity, '<>0');
        if SalesLine.IsEmpty() then
            Error(NothingToPostErr);
        if not Confirm(PostInvoiceQst, true, SalesHeader."No.") then
            exit;

        SalesHeader.Ship := true;
        SalesHeader.Invoice := true;
        Codeunit.Run(Codeunit::"Sales-Post", SalesHeader);

        if OpenNew then begin
            FastSalesMgt.CreateInvoice(SalesHeader);
            SalesHeader.SetRecFilter();
            Page.Run(Page::"PTV Fast Sales Invoice", SalesHeader);
        end;
        CurrPage.Close();
    end;

    local procedure IsOpenedOnExistingInvoice(): Boolean
    var
        NoFilter: Text;
    begin
        NoFilter := Rec.GetFilter("No.");
        if NoFilter = '' then begin
            Rec.FilterGroup(2);
            NoFilter := Rec.GetFilter("No.");
            Rec.FilterGroup(0);
        end;
        exit(IsSingleNoFilter(NoFilter));
    end;

    local procedure IsSingleNoFilter(NoFilter: Text): Boolean
    begin
        exit((NoFilter <> '') and
            (StrPos(NoFilter, '|') = 0) and
            (StrPos(NoFilter, '..') = 0) and
            (StrPos(NoFilter, '*') = 0) and
            (StrPos(NoFilter, '&') = 0) and
            (StrPos(NoFilter, '>') = 0) and
            (StrPos(NoFilter, '<') = 0));
    end;
}
