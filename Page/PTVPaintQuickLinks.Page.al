page 76080 "PTV Paint Quick Links"
{
    ApplicationArea = All;
    Caption = 'Paint Quick Links';
    PageType = CardPart;

    layout
    {
        area(Content)
        {
            cuegroup(DailyWork)
            {
                Caption = 'Daily Work';

                actions
                {
                    action(PaintProducts)
                    {
                        ApplicationArea = All;
                        Caption = 'Paint Products';
                        Image = TileBlue;
                        RunObject = page "PTV Paint Products";
                        ToolTip = 'Manage paint product families.';
                    }

                    action(ReleasedOrders)
                    {
                        ApplicationArea = All;
                        Caption = 'Released Production Orders';
                        Image = TileGreen;
                        RunObject = page "Released Production Orders";
                        ToolTip = 'Open released orders for batch work.';
                    }

                    action(QualityInspections)
                    {
                        ApplicationArea = All;
                        Caption = 'Quality Inspections';
                        Image = TileOrange;
                        RunObject = page "Qlty. Inspection List";
                        ToolTip = 'Review inspections and open a record to print its Certificate of Analysis.';
                    }

                    action(SalesOrders)
                    {
                        ApplicationArea = All;
                        Caption = 'Sales Orders';
                        Image = TileBlue;
                        RunObject = page "Sales Order List";
                        ToolTip = 'Open sales orders.';
                    }
                }
            }
        }
    }
}
