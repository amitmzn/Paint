page 76072 "PTV Fast Sales Inv. Subform"
{
    ApplicationArea = All;
    AutoSplitKey = true;
    Caption = 'Lines';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "Sales Line";
    SourceTableView = where("Document Type" = const(Invoice));

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field(Barcode; Barcode)
                {
                    Caption = 'Barcode';
                    ToolTip = 'Scan an item reference of type Bar Code. Each scan adds quantity 1 for that item.';
                    Visible = BarcodeVisible;

                    trigger OnValidate()
                    var
                        ScannedCode: Code[50];
                        FastSalesMgt: Codeunit "PTV Fast Sales Mgt";
                    begin
                        if Barcode = '' then
                            exit;
                        ScannedCode := Barcode;
                        Barcode := '';
                        FastSalesMgt.AddBarcode(Rec, ScannedCode);
                        CurrPage.Update(false);
                    end;
                }
                field(ItemNo; ItemNo)
                {
                    Caption = 'Item No.';
                    TableRelation = Item."No.";
                    ToolTip = 'Specifies the item number.';

                    trigger OnValidate()
                    var
                        DocumentMissingErr: Label 'Open a fast sales invoice before entering an item.';
                    begin
                        if Rec."Document No." = '' then
                            Error(DocumentMissingErr);
                        if ItemNo = '' then begin
                            if Rec."Line No." <> 0 then begin
                                Rec.Validate("No.", '');
                                Rec.Validate(Type, Rec.Type::" ");
                                Rec.Modify(true);
                            end;
                            exit;
                        end;
                        if Rec."Line No." = 0 then begin
                            Rec."Line No." := NextLineNo();
                            Rec.Insert(true);
                        end;
                        if Rec.Type <> Rec.Type::Item then
                            Rec.Validate(Type, Rec.Type::Item);
                        Rec.Validate("No.", ItemNo);
                        if Rec.Quantity = 0 then
                            Rec.Validate(Quantity, 1);
                        Rec.Modify(true);
                        RefreshTracking();
                    end;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the item description.';
                }
                field(Quantity; Rec.Quantity)
                {
                    ToolTip = 'Specifies the quantity to invoice.';
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ToolTip = 'Specifies the unit of measure.';
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ToolTip = 'Specifies the price per unit.';
                }
                field("Line Amount"; Rec."Line Amount")
                {
                    ToolTip = 'Specifies the line amount.';
                }
                field(TrackingStatus; TrackingStatus)
                {
                    Caption = 'Lot No.';
                    DrillDown = true;
                    Editable = false;
                    ToolTip = 'Specifies the lot or serial numbers. Shown only when the item uses manual tracking. Choose the value to enter tracking.';
                    Visible = ManualTracking;

                    trigger OnDrillDown()
                    begin
                        OpenTracking();
                    end;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ItemTrackingLines)
            {
                ApplicationArea = All;
                Caption = 'Item Tracking Lines';
                Enabled = ManualTracking;
                Image = ItemTrackingLines;
                ShortCutKey = 'Ctrl+Alt+I';
                ToolTip = 'Enter lot or serial numbers when this item uses manual tracking.';
                Visible = ManualTracking;

                trigger OnAction()
                begin
                    OpenTracking();
                end;
            }
        }
    }

    var
        Barcode: Code[50];
        ItemNo: Code[20];
        TrackingStatus: Text[100];
        BarcodeVisible: Boolean;
        ManualTracking: Boolean;

    trigger OnOpenPage()
    begin
        RefreshBarcodeVisibility();
    end;

    trigger OnAfterGetRecord()
    var
        FastSalesMgt: Codeunit "PTV Fast Sales Mgt";
    begin
        ItemNo := '';
        if Rec.Type = Rec.Type::Item then
            ItemNo := Rec."No.";
        TrackingStatus := FastSalesMgt.TrackingStatusText(Rec);
        RefreshBarcodeVisibility();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        RefreshBarcodeVisibility();
        RefreshTracking();
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        ItemNo := '';
        Barcode := '';
    end;

    local procedure NextLineNo(): Integer
    var
        LastLine: Record "Sales Line";
    begin
        LastLine.SetRange("Document Type", Rec."Document Type");
        LastLine.SetRange("Document No.", Rec."Document No.");
        if LastLine.FindLast() then
            exit(LastLine."Line No." + 10000);
        exit(10000);
    end;

    local procedure OpenTracking()
    var
        FastSalesMgt: Codeunit "PTV Fast Sales Mgt";
    begin
        FastSalesMgt.OpenItemTracking(Rec);
        RefreshTracking();
        CurrPage.Update(false);
    end;

    local procedure RefreshTracking()
    var
        FastSalesMgt: Codeunit "PTV Fast Sales Mgt";
    begin
        ManualTracking := FastSalesMgt.RequiresManualTracking(Rec);
        TrackingStatus := FastSalesMgt.TrackingStatusText(Rec);
    end;

    local procedure RefreshBarcodeVisibility()
    var
        SalesHeader: Record "Sales Header";
        FastSalesMgt: Codeunit "PTV Fast Sales Mgt";
    begin
        if SalesHeader.Get(Rec."Document Type", Rec."Document No.") then
            BarcodeVisible := FastSalesMgt.BarcodeScanningEnabled(SalesHeader."Location Code")
        else
            BarcodeVisible := FastSalesMgt.BarcodeScanningEnabled('');
    end;
}
