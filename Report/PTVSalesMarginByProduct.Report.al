report 76155 "PTV Sales Margin by Product"
{
    Caption = 'Sales Margin by Product/Shade';
    ApplicationArea = All;
    DefaultRenderingLayout = RDLC;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(SalesInvoiceLine; "Sales Invoice Line")
        {
            RequestFilterFields = "Posting Date", "PTV Product Code", "PTV Shade Code";
            DataItemTableView = where(Type = const(Item));
            column(ProductCode; "PTV Product Code") { }
            column(ShadeCode; "PTV Shade Code") { }
            column(SalesAmount; "Line Amount") { }
            column(CostAmount; CostAmount) { }
            column(MarginAmount; MarginAmount) { }

            trigger OnAfterGetRecord()
            var
                ValueEntry: Record "Value Entry";
            begin
                CostAmount := 0;
                ValueEntry.SetRange("Document Type", ValueEntry."Document Type"::"Sales Invoice");
                ValueEntry.SetRange("Document No.", "Document No.");
                ValueEntry.SetRange("Document Line No.", "Line No.");
                ValueEntry.SetLoadFields("Cost Amount (Actual)");
                if ValueEntry.FindSet() then
                    repeat
                        CostAmount += ValueEntry."Cost Amount (Actual)";
                    until ValueEntry.Next() = 0;
                MarginAmount := "Line Amount" + CostAmount;
            end;
        }
    }

    rendering
    {
        layout(RDLC)
        {
            Type = RDLC;
            LayoutFile = './layout/PTVSalesMargin.rdlc';
            Caption = 'Sales Margin by Product/Shade';
        }
    }

    var
        CostAmount: Decimal;
        MarginAmount: Decimal;
}
