page 76070 "PTV Fast Sales Stores"
{
    ApplicationArea = All;
    Caption = 'Fast Sales Stores';
    PageType = List;
    SourceTable = "PTV Fast Sales Store";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            repeater(Stores)
            {
                field("Location Code"; Rec."Location Code")
                {
                    ToolTip = 'Specifies the location that represents the store.';
                }
                field("Cash Customer No."; Rec."Cash Customer No.")
                {
                    ToolTip = 'Specifies the cash customer selected on a new fast sales invoice for this store.';
                }
                field("Responsibility Center"; Rec."Responsibility Center")
                {
                    ToolTip = 'Specifies the responsibility centre stamped on a new fast sales invoice for this store.';
                }
                field("Barcode Scanning"; Rec."Barcode Scanning")
                {
                    ToolTip = 'Specifies that the barcode field is shown on fast sales invoices for this store.';
                }
            }
        }
    }
}
