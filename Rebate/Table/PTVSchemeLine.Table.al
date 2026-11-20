table 77003 "PTV Scheme Line"
{
    Caption = 'Rebate Scheme Line';
    DataClassification = CustomerContent;

    fields
    {
        field(77000; "Scheme Code"; Code[20])
        {
            Caption = 'Scheme Code';
            DataClassification = CustomerContent;
            TableRelation = "PTV Scheme Header".Code;
        }
        field(77001; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(77002; "Line Type"; Enum "PTV Scheme Line Type")
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
        }
        field(77003; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(77004; "Scheme Product Group"; Code[20])
        {
            Caption = 'Scheme Product Group';
            DataClassification = CustomerContent;
            TableRelation = "PTV Scheme Product Group".Code;

            trigger OnValidate()
            var
                Grp: Record "PTV Scheme Product Group";
            begin
                if Grp.Get(Rec."Scheme Product Group") then begin
                    if Rec.Description = '' then
                        Rec.Description := Grp.Description;
                    if Rec."Min Growth %" = 0 then
                        Rec."Min Growth %" := Grp."Default Min Growth %";
                    Rec."Rebate Measure" := Grp."Rebate Measure";
                end;
            end;
        }
        field(77005; "Paint Product Code"; Code[20])
        {
            Caption = 'Paint Product Code';
            DataClassification = CustomerContent;
            TableRelation = "PTV Paint Product".Code;
        }
        field(77006; "Shade Code"; Code[20])
        {
            Caption = 'Shade Code';
            DataClassification = CustomerContent;
            TableRelation = "PTV Shade".Code;
        }
        field(77007; "Pack Code"; Code[20])
        {
            Caption = 'Pack Code';
            DataClassification = CustomerContent;
            TableRelation = "PTV Pack".Code;
        }
        field(77008; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item."No.";
        }
        field(77009; "Item Category Code"; Code[20])
        {
            Caption = 'Item Category Code';
            DataClassification = CustomerContent;
            TableRelation = "Item Category".Code;
        }
        field(77010; "Rebate Measure"; Enum "PTV Rebate Measure")
        {
            Caption = 'Quantity Measure';
            DataClassification = CustomerContent;
        }
        field(77011; "Min Growth %"; Decimal)
        {
            Caption = 'Min Growth %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
        }
        field(77012; "Minimum Quantity"; Decimal)
        {
            Caption = 'Minimum Quantity';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(77013; "Minimum Value"; Decimal)
        {
            Caption = 'Minimum Value';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(77014; "Target Quantity"; Decimal)
        {
            Caption = 'Target Quantity';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(77015; "Target Value"; Decimal)
        {
            Caption = 'Target Value';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(77016; "No. of Slabs"; Integer)
        {
            Caption = 'No. of Slabs';
            FieldClass = FlowField;
            CalcFormula = count("PTV Scheme Slab" where("Scheme Code" = field("Scheme Code"), "Scheme Line No." = field("Line No.")));
            Editable = false;
        }
        field(77017; "Sales UOM Filter"; Code[10])
        {
            Caption = 'Sales UOM Filter';
            DataClassification = CustomerContent;
            TableRelation = "Unit of Measure".Code;
        }
        field(77018; "Item Discount Group Filter"; Code[20])
        {
            Caption = 'Item Discount Group Filter';
            DataClassification = CustomerContent;
            TableRelation = "Item Discount Group".Code;
        }
        field(77019; "Paint Product Filter"; Text[100])
        {
            Caption = 'Paint Product Filter';
            DataClassification = CustomerContent;
        }
        field(77020; "Shade Filter"; Text[100])
        {
            Caption = 'Shade Filter';
            DataClassification = CustomerContent;
        }
        field(77021; "Pack Filter"; Text[100])
        {
            Caption = 'Pack Filter';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Scheme Code", "Line No.")
        {
            Clustered = true;
        }
        key(LineType; "Scheme Code", "Line Type")
        {
        }
    }

    trigger OnInsert()
    var
        SchemeHdr: Record "PTV Scheme Header";
    begin
        if (Rec."Min Growth %" = 0) and SchemeHdr.Get(Rec."Scheme Code") then
            Rec."Min Growth %" := SchemeHdr."Default Min Growth %";
    end;

    trigger OnDelete()
    var
        Slab: Record "PTV Scheme Slab";
    begin
        Slab.SetRange("Scheme Code", Rec."Scheme Code");
        Slab.SetRange("Scheme Line No.", Rec."Line No.");
        Slab.DeleteAll();
    end;
}
