page 76078 "PTV Paint Role Center"
{
    ApplicationArea = All;
    Caption = 'Paint Vertical';
    PageType = RoleCenter;

    layout
    {
        area(RoleCenter)
        {
            part(Headline; "PTV Paint Headline")
            {
                ApplicationArea = All;
            }
            part(QuickLinks; "PTV Paint Quick Links")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(Embedding)
        {
            action(FastSalesHome)
            {
                Caption = 'Counter Sales';
                RunObject = page "PTV Fast Sales Invoices";
                ToolTip = 'Open the list of counter sales invoices.';
            }
            action(RebateHome)
            {
                Caption = 'Rebate';
                ApplicationArea = All;
                RunObject = page "PTV Scheme List";
                ToolTip = 'Open the dealer rebate and incentive scheme list.';
            }
        }
        area(Sections)
        {
            group(MasterData)
            {
                Caption = 'Master Data';

                action(PaintProducts)
                {
                    Caption = 'Paint Products';
                    RunObject = page "PTV Paint Products";
                    ToolTip = 'Manage paint product families.';
                }

                action(PaintShades)
                {
                    Caption = 'Shades';
                    RunObject = page "PTV Shades";
                    ToolTip = 'Manage shade codes and colour targets.';
                }

                action(PaintPacks)
                {
                    Caption = 'Packs';
                    RunObject = page "PTV Packs";
                    ToolTip = 'Manage pack sizes and container units.';
                }

                action(InstructionMaster)
                {
                    Caption = 'Instruction Master';
                    RunObject = page "PTV Instruction Master";
                    ToolTip = 'Manage standard shop-floor manufacturing and mixing instructions.';
                }

                action(PaintItems)
                {
                    Caption = 'Paint Items';
                    RunObject = page "Item List";
                    RunPageView = where("PTV Product Code" = filter(<> ''));
                    ToolTip = 'View items assigned to a paint product.';
                }

                action(ItemApproval)
                {
                    Caption = 'Item Approval';
                    RunObject = page "PTV Item Approval";
                    ToolTip = 'Review blocked items awaiting approval.';
                }
            }

            group(Production)
            {
                Caption = 'Production';

                action(ReleasedOrders)
                {
                    Caption = 'Released Production Orders';
                    RunObject = page "Released Production Orders";
                    ToolTip = 'Open released orders for batch work.';
                }

                action(PlannedOrders)
                {
                    Caption = 'Firm Planned Production Orders';
                    RunObject = page "Firm Planned Prod. Orders";
                    ToolTip = 'Open firm planned production orders, including proposed rework.';
                }

                action(FinishedOrders)
                {
                    Caption = 'Finished Production Orders';
                    RunObject = page "Finished Production Orders";
                    ToolTip = 'Review completed production orders.';
                }

                action(Formulas)
                {
                    Caption = 'Production BOMs and Instructions';
                    RunObject = page "Production BOM List";
                    ToolTip = 'Open a production BOM to review its formula and paint instructions.';
                }

                action(Routings)
                {
                    Caption = 'Routings';
                    RunObject = page "Routing List";
                    ToolTip = 'Manage shop floor operations.';
                }

                action(Substitutes)
                {
                    Caption = 'Component Substitutes';
                    RunObject = page "PTV Substitute Items";
                    ToolTip = 'Maintain substitute materials and conversion factors.';
                }
            }

            group(Quality)
            {
                Caption = 'Quality';

                action(PaintSpecs)
                {
                    Caption = 'Paint QC Specifications';
                    RunObject = page "PTV QC Paint Specs";
                    ToolTip = 'Maintain paint test limits by item and shade.';
                }

                action(QualityInspections)
                {
                    Caption = 'Quality Inspections';
                    RunObject = page "Qlty. Inspection List";
                    ToolTip = 'Review inspections and open a record to print its Certificate of Analysis.';
                }

                action(QualityTemplates)
                {
                    Caption = 'Inspection Templates';
                    RunObject = page "Qlty. Inspection Template List";
                    ToolTip = 'Review the templates used for inspections.';
                }

                action(QualityRules)
                {
                    Caption = 'Inspection Generation Rules';
                    RunObject = page "Qlty. Inspection Gen. Rules";
                    ToolTip = 'Set where and when Business Central creates inspections.';
                }
            }

            group(PurchasingInventory)
            {
                Caption = 'Purchasing & Inventory';

                action(PurchaseOrders)
                {
                    Caption = 'Purchase Orders';
                    RunObject = page "Purchase Orders";
                    ToolTip = 'Open purchase orders.';
                }

                action(PostedReceipts)
                {
                    Caption = 'Posted Purchase Receipts';
                    RunObject = page "Posted Purchase Receipts";
                    ToolTip = 'Review posted receipts.';
                }

                action(ItemLedger)
                {
                    Caption = 'Item Ledger Entries';
                    RunObject = page "Item Ledger Entries";
                    ToolTip = 'Trace inventory movements and look up lot inspections.';
                }

                action(Lots)
                {
                    Caption = 'Lot Information';
                    RunObject = page "Lot No. Information List";
                    ToolTip = 'Review item lot records.';
                }

                action(Transfers)
                {
                    Caption = 'Transfer Orders';
                    RunObject = page "Transfer Orders";
                    ToolTip = 'Review inventory transfers.';
                }
            }

            group(Sales)
            {
                Caption = 'Sales & Counter';

                action(SalesOrders)
                {
                    Caption = 'Sales Orders';
                    RunObject = page "Sales Order List";
                    ToolTip = 'Open sales orders.';
                }

                action(PostedSalesInvoices)
                {
                    Caption = 'Posted Sales Invoices';
                    RunObject = page "Posted Sales Invoices";
                    ToolTip = 'Review posted sales invoices.';
                }

                action(FastSalesInvoice)
                {
                    Caption = 'New Counter Sales Invoice';
                    RunObject = page "PTV Fast Sales Invoice";
                    ToolTip = 'Start a counter invoice.';
                }

                action(FastSalesInvoices)
                {
                    Caption = 'Counter Sales Invoices';
                    RunObject = page "PTV Fast Sales Invoices";
                    ToolTip = 'View open counter invoices.';
                }

                action(PostedFastSales)
                {
                    Caption = 'Posted Counter Sales Invoices';
                    RunObject = page "PTV Posted Fast Sales";
                    ToolTip = 'View posted counter invoices.';
                }
            }

            group(Setup)
            {
                Caption = 'Setup';

                action(PaintSetup)
                {
                    Caption = 'Paint Setup';
                    RunObject = page "PTV Paint Setup";
                    ToolTip = 'Configure paint number series and processing options.';
                }

                action(RequiredFields)
                {
                    Caption = 'Mandatory Field Setup';
                    RunObject = page "PTV Mandatory Field Setup";
                    ToolTip = 'Define required item fields by paint role.';
                }

                action(QualitySetup)
                {
                    Caption = 'Quality Management Setup';
                    RunObject = page "Qlty. Management Setup";
                    ToolTip = 'Configure Microsoft Quality Management.';
                }

                action(CounterStores)
                {
                    Caption = 'Counter Sales Stores';
                    RunObject = page "PTV Fast Sales Stores";
                    ToolTip = 'Configure stores and their cash customers.';
                }

                action(UserSetup)
                {
                    Caption = 'User Setup';
                    RunObject = page "User Setup";
                    ToolTip = 'Assign counter users to stores.';
                }
            }
        }
        area(Processing)
        {
            action(GenerateSKUs)
            {
                Caption = 'Generate Paint SKUs';
                Image = NewDocument;
                RunObject = report "PTV SKU Matrix Request";
                ToolTip = 'Generate items from selected product, shade, and pack combinations.';
            }
        }
        area(Reporting)
        {
            action(BatchSheet)
            {
                Caption = 'Batch Sheet';
                Image = Report;
                RunObject = report "PTV Batch Sheet";
                ToolTip = 'Open the Batch Sheet report.';
            }

            action(GoodsReceipt)
            {
                Caption = 'GRN Receipt';
                Image = Report;
                RunObject = report "PTV GRN Receipt";
                ToolTip = 'Open the goods receipt report.';
            }

            action(Expiry)
            {
                Caption = 'Expiry and Non-Moving Inventory';
                Image = Report;
                RunObject = report "PTV Item Expiry & Non-Moving";
                ToolTip = 'Open the expiry and inventory ageing report.';
            }

            action(ProductionDispatch)
            {
                Caption = 'Production vs Dispatch';
                Image = Report;
                RunObject = report "PTV Production vs Despatch";
                ToolTip = 'Open the production and dispatch report.';
            }

            action(Margin)
            {
                Caption = 'Sales Margin by Product and Shade';
                Image = Report;
                RunObject = report "PTV Sales Margin by Product";
                ToolTip = 'Open the sales margin report.';
            }

            action(OTIF)
            {
                Caption = 'OTIF Scorecard';
                Image = Report;
                RunObject = report "PTV OTIF Scorecard";
                ToolTip = 'Open the shipment performance report.';
            }

            action(RightFirstTime)
            {
                Caption = 'Quality Right First Time';
                Image = Report;
                RunObject = report "PTV QC RFT Analysis";
                ToolTip = 'Open the first inspection pass report.';
            }
        }
    }
}
