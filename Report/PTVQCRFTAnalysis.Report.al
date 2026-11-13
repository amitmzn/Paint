report 76157 "PTV QC RFT Analysis"
{
    Caption = 'QC Right-First-Time Analysis';
    ApplicationArea = All;
    DefaultRenderingLayout = RDLC;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(QltyInspectionHeader; "Qlty. Inspection Header")
        {
            DataItemTableView = where("Re-inspection No." = const(0), Status = const(Finished));
            RequestFilterFields = "Finished Date", "Source Item No.";
            column(InspectionNo; "No.") { }
            column(ItemNo; "Source Item No.") { }
            column(ShadeCode; "PTV Shade Code") { }
            column(LotNo; "Source Lot No.") { }
            column(ResultCode; "Result Code") { }
            column(FinishedDate; "Finished Date") { }
            column(FirstPass; FirstPass) { }

            trigger OnAfterGetRecord()
            begin
                FirstPass := "Result Code" = 'PASS';
            end;
        }
    }

    rendering
    {
        layout(RDLC)
        {
            Type = RDLC;
            LayoutFile = './layout/PTVQCRightFirstTime.rdlc';
            Caption = 'QC Right-First-Time Analysis';
        }
    }

    var
        FirstPass: Boolean;
}
