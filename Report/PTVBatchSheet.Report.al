report 76150 "PTV Batch Sheet"
{
    Caption = 'Batch Sheet';
    ApplicationArea = All;
    DefaultRenderingLayout = RDLC;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(ProdOrder; "Production Order")
        {
            RequestFilterFields = Status, "No.";
            column(OrderNo; "No.") { }
            column(BatchNo; "PTV Batch No.") { }
            column(FormulaNo; "PTV Formula No.") { }
            column(ShadeCode; "PTV Shade Code") { }
            column(SpecificGravity; "PTV Specific Gravity") { }
            column(SourceNo; "Source No.") { }
            column(Quantity; Quantity) { }
            column(TargetKg; TargetKg) { }
            column(LabL; LabL) { }
            column(Laba; Laba) { }
            column(Labb; Labb) { }

            dataitem(ProdOrderLine; "Prod. Order Line")
            {
                DataItemLink = Status = field(Status), "Prod. Order No." = field("No.");
                column(LineItemNo; "Item No.") { }
                column(BomNo; "Production BOM No.") { }
                column(BomVersion; "Production BOM Version Code") { }

                dataitem(Component; "Prod. Order Component")
                {
                    DataItemLink = Status = field(Status), "Prod. Order No." = field("Prod. Order No."), "Prod. Order Line No." = field("Line No.");
                    DataItemTableView = sorting("Prod. Order No.");
                    column(ComponentItemNo; "Item No.") { }
                    column(ComponentDescription; Description) { }
                    column(ComponentQty; "Expected Quantity") { }
                    column(ComponentUom; "Unit of Measure Code") { }
                    column(ReservedLot; ReservedLot) { }

                    trigger OnAfterGetRecord()
                    begin
                        ReservedLot := FindReservedLot();
                    end;
                }

                dataitem(Instruction; "PTV BOM Instruction")
                {
                    DataItemLink = "BOM No." = field("Production BOM No."), "Version Code" = field("Production BOM Version Code");
                    column(StepNo; "Step No.") { }
                    column(InstructionText; Instruction) { }
                    column(MinTemp; "Min Temp C") { }
                    column(MaxTemp; "Max Temp C") { }
                    column(Rpm; "Agitation RPM") { }
                    column(DurationMin; "Duration Min") { }
                    column(QcCheckpoint; "QC Checkpoint") { }
                }
            }

            dataitem(QltyTest; "Qlty. Test")
            {
                DataItemTableView = sorting(Code) where(Code = filter('SG|KU|GRIND|DE'));
                column(TestCode; Code) { }
                column(TestDescription; Description) { }
                column(TestUom; "Unit of Measure Code") { }
            }

            trigger OnAfterGetRecord()
            var
                Shade: Record "PTV Shade";
                UomMgt: Codeunit "PTV UOM Mgt";
            begin
                TargetKg := UomMgt.WeightFromVolume(Quantity, "PTV Specific Gravity");
                LabL := 0;
                Laba := 0;
                Labb := 0;
                Shade.SetLoadFields("Lab L Target", "Lab a Target", "Lab b Target");
                if Shade.Get("PTV Shade Code") then begin
                    LabL := Shade."Lab L Target";
                    Laba := Shade."Lab a Target";
                    Labb := Shade."Lab b Target";
                end;
            end;
        }
    }

    rendering
    {
        layout(RDLC)
        {
            Type = RDLC;
            LayoutFile = './layout/PTVBatchSheet.rdlc';
            Caption = 'Batch Sheet';
        }
    }

    var
        TargetKg: Decimal;
        LabL: Decimal;
        Laba: Decimal;
        Labb: Decimal;
        ReservedLot: Code[50];

    local procedure FindReservedLot(): Code[50]
    var
        ReservationEntry: Record "Reservation Entry";
    begin
        ReservationEntry.SetRange("Source Type", Database::"Prod. Order Component");
        ReservationEntry.SetRange("Source ID", Component."Prod. Order No.");
        ReservationEntry.SetRange("Source Prod. Order Line", Component."Prod. Order Line No.");
        ReservationEntry.SetRange("Source Ref. No.", Component."Line No.");
        ReservationEntry.SetFilter("Lot No.", '<>%1', '');
        ReservationEntry.SetLoadFields("Lot No.");
        if ReservationEntry.FindFirst() then
            exit(ReservationEntry."Lot No.");
    end;
}
