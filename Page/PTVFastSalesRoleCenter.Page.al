page 76076 "PTV Fast Sales Role Center"
{
    ApplicationArea = All;
    Caption = 'Counter Sales';
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
                Caption = 'Counter Sales Invoices';
                RunObject = page "PTV Fast Sales Invoices";
                ToolTip = 'Open the counter sales invoices for your responsibility centre.';
            }
            action(PostedFastSales)
            {
                Caption = 'Posted Counter Sales Invoices';
                RunObject = page "PTV Posted Fast Sales";
                ToolTip = 'Open posted counter sales invoices for your responsibility centre.';
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
                    Caption = 'Counter Sales Invoice';
                    RunObject = page "PTV Fast Sales Invoice";
                    ToolTip = 'Start a counter sales invoice for the store cash customer.';
                }
                action(OpenFastSalesInvoices)
                {
                    Caption = 'Counter Sales Invoices';
                    RunObject = page "PTV Fast Sales Invoices";
                    ToolTip = 'View open counter sales invoices.';
                }
                action(PostedFastSalesInvoices)
                {
                    Caption = 'Posted Counter Sales Invoices';
                    RunObject = page "PTV Posted Fast Sales";
                    ToolTip = 'View posted counter sales invoices.';
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
                    Caption = 'Counter Sales Stores';
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
                Caption = 'Counter Sales Invoice';
                Image = NewDocument;
                RunObject = page "PTV Fast Sales Invoice";
                ToolTip = 'Start a counter sales invoice for the store cash customer.';
            }
        }
    }
}
