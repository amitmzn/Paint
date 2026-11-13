report 76151 "PTV GRN Receipt"
{
    Caption = 'GRN Receipt';
    ApplicationArea = All;
    DefaultRenderingLayout = RDLC;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(PurchRcptHeader; "Purch. Rcpt. Header")
        {
            RequestFilterFields = "No.", "Buy-from Vendor No.", "Posting Date";
            column(ReceiptNo; "No.") { }
            column(BuyFromVendorNo; "Buy-from Vendor No.") { }
            column(BuyFromVendorName; "Buy-from Vendor Name") { }
            column(PostingDate; "Posting Date") { }
            column(OrderNo; "Order No.") { }
            column(VoyageNo; VoyageNo) { }
            column(ContainerNo; ContainerNo) { }
            column(PortOfLoading; PortOfLoading) { }
            column(PortOfDischarge; PortOfDischarge) { }

            dataitem(PurchRcptLine; "Purch. Rcpt. Line")
            {
                DataItemLink = "Document No." = field("No.");
                DataItemTableView = where(Type = const(Item));
                column(LineNo; "Line No.") { }
                column(ItemNo; "No.") { }
                column(Description; Description) { }
                column(Quantity; Quantity) { }
                column(UnitOfMeasure; "Unit of Measure Code") { }
                column(ShadeCode; ShadeCode) { }
                column(PackCode; PackCode) { }

                trigger OnAfterGetRecord()
                var
                    Item: Record Item;
                begin
                    Item.SetLoadFields("PTV Shade Code", "PTV Pack Code");
                    ShadeCode := '';
                    PackCode := '';
                    if Item.Get("No.") then begin
                        ShadeCode := Item."PTV Shade Code";
                        PackCode := Item."PTV Pack Code";
                    end;
                end;
            }

            trigger OnAfterGetRecord()
            var
                PurchaseHeader: Record "Purchase Header";
            begin
                VoyageNo := '';
                ContainerNo := '';
                PortOfLoading := '';
                PortOfDischarge := '';
                PurchaseHeader.SetLoadFields("PTV Voyage No.", "PTV Container No.", "PTV Port of Loading", "PTV Port of Discharge");
                if PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, "Order No.") then begin
                    VoyageNo := PurchaseHeader."PTV Voyage No.";
                    ContainerNo := PurchaseHeader."PTV Container No.";
                    PortOfLoading := PurchaseHeader."PTV Port of Loading";
                    PortOfDischarge := PurchaseHeader."PTV Port of Discharge";
                end;
            end;
        }
    }

    rendering
    {
        layout(RDLC)
        {
            Type = RDLC;
            LayoutFile = './layout/PTVGRNReceipt.rdlc';
            Caption = 'GRN Receipt';
        }
    }

    var
        VoyageNo: Code[20];
        ContainerNo: Code[20];
        PortOfLoading: Text[50];
        PortOfDischarge: Text[50];
        ShadeCode: Code[20];
        PackCode: Code[20];
}
