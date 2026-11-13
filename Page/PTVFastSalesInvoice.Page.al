page 76071 "PTV Fast Sales Invoice"
{
    ApplicationArea = All;
    Caption = 'Fast Sales Invoice';
    PageType = Document;
    SourceTable = "Sales Header";
    SourceTableView = where("Document Type" = const(Invoice), "PTV Fast Sales" = const(true));
    UsageCategory = Documents;
    RefreshOnActivate = true;
    InsertAllowed = false;
    AdditionalSearchTerms = 'POS,Cash Sale,Fast Sales';

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
                field("Sell-to Customer No."; Rec."Sell-to Customer No.")
                {
                    Caption = 'Cash Customer';
                    ToolTip = 'Specifies the cash customer. A new invoice selects the customer for your store.';

                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                field("Location Code"; Rec."Location Code")
                {
                    Caption = 'Store';
                    ToolTip = 'Specifies the store location.';

                    trigger OnValidate()
                    begin
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
    begin
        CurrPage.SaveRecord();
        SalesHeader.Get(Rec."Document Type", Rec."No.");
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
