page 76076 "PTV Fast Sales Role Center"
{
    ApplicationArea = All;
    Caption = 'Fast Sales';
    PageType = RoleCenter;

    layout
    {
        area(RoleCenter)
        {
            part(Headline; "PTV Fast Sales Headline")
            {
                ApplicationArea = All;
            }
            part(Activities; "PTV Fast Sales Activities")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(Embedding)
        {
            action(FastSalesInvoices)
            {
                Caption = 'Fast Sales Invoices';
                RunObject = page "PTV Fast Sales Invoices";
                ToolTip = 'Open the fast sales invoices for your responsibility centre.';
            }
            action(PostedFastSales)
            {
                Caption = 'Posted Fast Sales';
                RunObject = page "PTV Posted Fast Sales";
                ToolTip = 'Open posted fast sales invoices for your responsibility centre.';
            }
            action(Customers)
            {
                Caption = 'Customers';
                RunObject = page "Customer List";
                ToolTip = 'Open the customer list.';
            }
            action(Items)
            {
                Caption = 'Items';
                RunObject = page "Item List";
                ToolTip = 'Open the item list.';
            }
        }
        area(Sections)
        {
            group(Sales)
            {
                Caption = 'Sales';
                action(NewFastSalesInvoice)
                {
                    Caption = 'Fast Sales Invoice';
                    RunObject = page "PTV Fast Sales Invoice";
                    ToolTip = 'Start a fast sales invoice for the store cash customer.';
                }
                action(OpenFastSalesInvoices)
                {
                    Caption = 'Fast Sales Invoices';
                    RunObject = page "PTV Fast Sales Invoices";
                    ToolTip = 'View open fast sales invoices.';
                }
                action(PostedFastSalesInvoices)
                {
                    Caption = 'Posted Fast Sales Invoices';
                    RunObject = page "PTV Posted Fast Sales";
                    ToolTip = 'View posted fast sales invoices.';
                }
            }
            group(Setup)
            {
                Caption = 'Setup';
                action(PaintSetup)
                {
                    Caption = 'Paint Setup';
                    RunObject = page "PTV Paint Setup";
                    ToolTip = 'Set the role center heading, default cash customer, and barcode scanning.';
                }
                action(FastSalesStores)
                {
                    Caption = 'Fast Sales Stores';
                    RunObject = page "PTV Fast Sales Stores";
                    ToolTip = 'Set the cash customer and responsibility centre for each store.';
                }
                action(UserSetup)
                {
                    Caption = 'User Setup';
                    RunObject = page "User Setup";
                    ToolTip = 'Assign each user to a store.';
                }
            }
        }
        area(Creation)
        {
            action(NewInvoice)
            {
                Caption = 'Fast Sales Invoice';
                Image = NewDocument;
                RunObject = page "PTV Fast Sales Invoice";
                ToolTip = 'Start a fast sales invoice for the store cash customer.';
            }
        }
    }
}
