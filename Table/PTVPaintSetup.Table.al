table 76000 "PTV Paint Setup"
{
    Caption = 'Paint Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(76000; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = SystemMetadata;
        }
        field(76001; "Block Items On Creation"; Boolean)
        {
            Caption = 'Block Items On Creation';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(76002; "Mandatory Fields"; Boolean)
        {
            Caption = 'Mandatory Fields';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(76003; "Propagate PSP"; Boolean)
        {
            Caption = 'Propagate Product/Shade/Pack';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(76004; "QC Gate On Invoice Posting"; Boolean)
        {
            Caption = 'QC Gate On Invoice Posting';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(76005; "Auto Reserve On Release"; Boolean)
        {
            Caption = 'Auto Reserve Components On Release';
            DataClassification = CustomerContent;
            InitValue = false;
        }
        field(76006; "Align Output ValDate"; Boolean)
        {
            Caption = 'Align Output Valuation Date';
            DataClassification = CustomerContent;
            InitValue = false;
        }
        field(76007; "Quarantine Location"; Code[10])
        {
            Caption = 'Quarantine Location';
            DataClassification = CustomerContent;
            TableRelation = Location.Code;
        }
        field(76008; "Quarantine Bin"; Code[20])
        {
            Caption = 'Quarantine Bin';
            DataClassification = CustomerContent;
            TableRelation = Bin.Code where("Location Code" = field("Quarantine Location"));
        }
        field(76009; "Batch Nos."; Code[20])
        {
            Caption = 'Batch Nos.';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(76010; "SKU Item Nos."; Code[20])
        {
            Caption = 'SKU Item Nos.';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(76011; "Default Cash Customer"; Code[20])
        {
            Caption = 'Default Cash Customer';
            DataClassification = CustomerContent;
            TableRelation = Customer."No.";
        }
        field(76012; "Fast Sales Barcode"; Boolean)
        {
            Caption = 'Barcode Scanning';
            DataClassification = CustomerContent;
        }
        field(76013; "Role Center Heading"; Enum "PTV Role Center Heading")
        {
            Caption = 'Role Center Heading';
            DataClassification = CustomerContent;
        }
        field(76014; "Custom Role Center Heading"; Text[100])
        {
            Caption = 'Custom Heading';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    /// <summary>
    /// Gets the single setup record, inserting the defaults when it is missing.
    /// </summary>
    procedure GetSetup()
    begin
        if Get('SETUP') then
            exit;
        Init();
        "Primary Key" := 'SETUP';
        Insert(true);
    end;
}
