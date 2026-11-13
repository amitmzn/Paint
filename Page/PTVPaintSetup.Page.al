page 76060 "PTV Paint Setup"
{
    ApplicationArea = All;
    Caption = 'Paint Setup';
    PageType = Card;
    SourceTable = "PTV Paint Setup";
    UsageCategory = Administration;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("Block Items On Creation"; Rec."Block Items On Creation")
                {
                    ToolTip = 'Specifies that new items are blocked until approval.';
                }
                field("Mandatory Fields"; Rec."Mandatory Fields")
                {
                    ToolTip = 'Specifies that mandatory paint fields are checked before approval.';
                }
                field("Propagate PSP"; Rec."Propagate PSP")
                {
                    ToolTip = 'Specifies that product, shade and pack copy from the item onto documents.';
                }
                field("QC Gate On Invoice Posting"; Rec."QC Gate On Invoice Posting")
                {
                    ToolTip = 'Specifies that a purchase invoice cannot exceed the quantity accepted by Quality Management.';
                }
                field("Auto Reserve Components On Release"; Rec."Auto Reserve On Release")
                {
                    ToolTip = 'Specifies that component reservations are created when a production order is released. Default is off.';
                }
                field("Align Output ValDate"; Rec."Align Output ValDate")
                {
                    ToolTip = 'Specifies that output valuation date follows the latest consumption valuation date. Default is off.';
                }
            }
            group(NumberSeries)
            {
                Caption = 'Number Series';
                field("Batch Nos."; Rec."Batch Nos.")
                {
                    ToolTip = 'Specifies the number series used as the finished-goods batch and lot number.';
                }
                field("SKU Item Nos."; Rec."SKU Item Nos.")
                {
                    ToolTip = 'Specifies the number series used when the SKU matrix creates items.';
                }
            }
            group(FastSales)
            {
                Caption = 'Fast Sales';
                field("Default Cash Customer"; Rec."Default Cash Customer")
                {
                    ToolTip = 'Specifies the cash customer used when the user has no store on User Setup.';
                }
                field("Fast Sales Barcode"; Rec."Fast Sales Barcode")
                {
                    ToolTip = 'Specifies that barcode scanning is available when the invoice has no store setup row.';
                }
            }
            group(Quarantine)
            {
                Caption = 'Quarantine';
                field("Quarantine Location"; Rec."Quarantine Location")
                {
                    ToolTip = 'Specifies the location that mirrors the Quality Management quarantine location.';
                }
                field("Quarantine Bin"; Rec."Quarantine Bin")
                {
                    ToolTip = 'Specifies the bin that mirrors the Quality Management quarantine bin.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(FastSalesStores)
            {
                ApplicationArea = All;
                Caption = 'Fast Sales Stores';
                Image = Setup;
                RunObject = page "PTV Fast Sales Stores";
                ToolTip = 'Set the cash customer, responsibility centre, and barcode scanning for each store.';
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.GetSetup();
    end;
}
