report 76156 "PTV OTIF Scorecard"
{
    Caption = 'OTIF Scorecard';
    ApplicationArea = All;
    DefaultRenderingLayout = RDLC;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(SalesShipmentLine; "Sales Shipment Line")
        {
            RequestFilterFields = "Posting Date", "Sell-to Customer No.";
            DataItemTableView = where(Type = const(Item), Quantity = filter('>0'));
            column(ShipmentNo; "Document No.") { }
            column(LineNo; "Line No.") { }
            column(ItemNo; "No.") { }
            column(ProductCode; "PTV Product Code") { }
            column(ShadeCode; "PTV Shade Code") { }
            column(OnTime; "PTV On Time") { }
            column(InFull; "PTV In Full") { }
            column(Quantity; Quantity) { }
        }
    }

    rendering
    {
        layout(RDLC)
        {
            Type = RDLC;
            LayoutFile = './layout/PTVOTIFScorecard.rdlc';
            Caption = 'OTIF Scorecard';
        }
    }
}
