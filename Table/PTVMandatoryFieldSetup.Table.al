table 76004 "PTV Mandatory Field Setup"
{
    Caption = 'Mandatory Field Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(76000; "Table No."; Integer)
        {
            Caption = 'Table No.';
            DataClassification = SystemMetadata;
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
        }
        field(76001; "Field No."; Integer)
        {
            Caption = 'Field No.';
            DataClassification = SystemMetadata;
            TableRelation = Field."No." where(TableNo = field("Table No."));
        }
        field(76002; "Item Role"; Enum "PTV Item Role")
        {
            Caption = 'Item Role';
            DataClassification = CustomerContent;
        }
        field(76003; Active; Boolean)
        {
            Caption = 'Active';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(76004; "Field Caption"; Text[80])
        {
            Caption = 'Field Caption';
            FieldClass = FlowField;
            CalcFormula = lookup(Field."Field Caption" where(TableNo = field("Table No."), "No." = field("Field No.")));
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Table No.", "Field No.", "Item Role")
        {
            Clustered = true;
        }
    }
}
