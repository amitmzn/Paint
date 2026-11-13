tableextension 76030 "PTV Item" extends Item
{
    fields
    {
        field(76000; "PTV Product Code"; Code[20])
        {
            Caption = 'Paint Product Code';
            DataClassification = CustomerContent;
            TableRelation = "PTV Paint Product".Code where(Blocked = const(false));
        }
        field(76001; "PTV Shade Code"; Code[20])
        {
            Caption = 'Shade Code';
            DataClassification = CustomerContent;
            TableRelation = "PTV Shade".Code where(Blocked = const(false));
        }
        field(76002; "PTV Pack Code"; Code[20])
        {
            Caption = 'Pack Code';
            DataClassification = CustomerContent;
            TableRelation = "PTV Pack".Code where(Blocked = const(false));

            trigger OnValidate()
            var
                PTVUOMMgt: Codeunit "PTV UOM Mgt";
            begin
                if "PTV Pack Code" <> xRec."PTV Pack Code" then
                    PTVUOMMgt.MaintainItemUOMFromPack(Rec);
            end;
        }
        field(76003; "PTV Specific Gravity"; Decimal)
        {
            Caption = 'Specific Gravity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 4;
            MinValue = 0;

            trigger OnValidate()
            var
                PTVUOMMgt: Codeunit "PTV UOM Mgt";
            begin
                "PTV Weight Per Litre" := "PTV Specific Gravity";
                PTVUOMMgt.MaintainKgUom(Rec);
            end;
        }
        field(76004; "PTV QC Enabled"; Boolean)
        {
            Caption = 'QC Enabled';
            DataClassification = CustomerContent;
        }
        field(76005; "PTV QC Template Code"; Code[20])
        {
            Caption = 'QC Inspection Template Code';
            DataClassification = CustomerContent;
            TableRelation = "Qlty. Inspection Template Hdr.".Code;
        }
        field(76006; "PTV Weight Per Litre"; Decimal)
        {
            Caption = 'Weight Per Litre';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 4;
            Editable = false;
        }
        field(76007; "PTV Solids By Volume %"; Decimal)
        {
            Caption = 'Solids By Volume %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
            MinValue = 0;
            MaxValue = 100;
        }
        field(76008; "PTV Solids By Weight %"; Decimal)
        {
            Caption = 'Solids By Weight %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
            MinValue = 0;
            MaxValue = 100;
        }
        field(76009; "PTV Binder Content %"; Decimal)
        {
            Caption = 'Binder Content %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
            MinValue = 0;
            MaxValue = 100;
        }
        field(76010; "PTV VOC g/L"; Decimal)
        {
            Caption = 'VOC (g/L)';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
            MinValue = 0;
        }
        field(76011; "PTV VOC Category"; Code[20])
        {
            Caption = 'VOC Category';
            DataClassification = CustomerContent;
        }
        field(76012; "PTV Item Role"; Enum "PTV Item Role")
        {
            Caption = 'Item Role';
            DataClassification = CustomerContent;
        }
        field(76013; "PTV Shelf Life"; DateFormula)
        {
            Caption = 'Shelf Life';
            DataClassification = CustomerContent;
        }
        field(76014; "PTV Item Approved"; Boolean)
        {
            Caption = 'Item Approved';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(76015; "PTV Created On"; Date)
        {
            Caption = 'Created On';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(76016; "PTV Approved By"; Code[50])
        {
            Caption = 'Approved By';
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
            TableRelation = User."User Name";
        }
        field(76017; "PTV Approved On"; Date)
        {
            Caption = 'Approved On';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(PTVProductShadePack; "PTV Product Code", "PTV Shade Code", "PTV Pack Code")
        {
        }
        key(PTVQCEnabled; "PTV QC Enabled")
        {
        }
    }
}
