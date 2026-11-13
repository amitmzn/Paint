report 76154 "PTV Production vs Despatch"
{
    Caption = 'Production vs Despatch';
    ApplicationArea = All;
    DefaultRenderingLayout = RDLC;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Item; Item)
        {
            RequestFilterFields = "No.", "PTV Product Code", "PTV Shade Code";
            DataItemTableView = where("PTV Item Role" = filter("FG Paint"|Bulk|"Tinted Base"));
            column(ItemNo; "No.") { }
            column(ProductCode; "PTV Product Code") { }
            column(ShadeCode; "PTV Shade Code") { }
            column(ManufacturedLitres; ManufacturedLitres) { }
            column(ShippedLitres; ShippedLitres) { }

            trigger OnAfterGetRecord()
            var
                UomMgt: Codeunit "PTV UOM Mgt";
                ItemLedgerEntry: Record "Item Ledger Entry";
            begin
                ManufacturedLitres := 0;
                ShippedLitres := 0;
                ItemLedgerEntry.SetRange("Item No.", "No.");
                ItemLedgerEntry.SetRange("Posting Date", StartDate, EndDate);
                ItemLedgerEntry.SetLoadFields("Entry Type", Quantity, "Unit of Measure Code");
                if ItemLedgerEntry.FindSet() then
                    repeat
                        if ItemLedgerEntry."Entry Type" = ItemLedgerEntry."Entry Type"::Output then
                            ManufacturedLitres += UomMgt.LineQuantityToLitres("No.", ItemLedgerEntry."Unit of Measure Code", ItemLedgerEntry.Quantity);
                        if ItemLedgerEntry."Entry Type" = ItemLedgerEntry."Entry Type"::Sale then
                            ShippedLitres += UomMgt.LineQuantityToLitres("No.", ItemLedgerEntry."Unit of Measure Code", -ItemLedgerEntry.Quantity);
                    until ItemLedgerEntry.Next() = 0;
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Period)
                {
                    Caption = 'Period';
                    field(StartDate; StartDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Start Date';
                        ToolTip = 'Specifies the first posting date.';
                    }
                    field(EndDate; EndDate)
                    {
                        ApplicationArea = All;
                        Caption = 'End Date';
                        ToolTip = 'Specifies the last posting date.';
                    }
                }
            }
        }
    }

    rendering
    {
        layout(RDLC)
        {
            Type = RDLC;
            LayoutFile = './layout/PTVProductionVsDespatch.rdlc';
            Caption = 'Production vs Despatch';
        }
    }

    var
        StartDate: Date;
        EndDate: Date;
        ManufacturedLitres: Decimal;
        ShippedLitres: Decimal;
}
