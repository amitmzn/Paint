table 77000 "PTV Rebate Setup"
{
    Caption = 'Rebate & Scheme Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(77000; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = SystemMetadata;
        }
        field(77001; "Scheme Nos."; Code[20])
        {
            Caption = 'Scheme Nos.';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(77002; "Default Rebate G/L Account"; Code[20])
        {
            Caption = 'Default Rebate G/L Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account"."No.";
        }
        field(77003; "Default Provision G/L Acc."; Code[20])
        {
            Caption = 'Default Provision G/L Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account"."No.";
        }
        field(77004; "Journal Template Name"; Code[10])
        {
            Caption = 'Journal Template Name';
            DataClassification = CustomerContent;
            TableRelation = "Gen. Journal Template".Name;
        }
        field(77005; "Journal Batch Name"; Code[10])
        {
            Caption = 'Journal Batch Name';
            DataClassification = CustomerContent;
            TableRelation = "Gen. Journal Batch".Name where("Journal Template Name" = field("Journal Template Name"));
        }
        field(77006; "Auto Detect Special Price"; Boolean)
        {
            Caption = 'Auto Detect Special Price';
            DataClassification = CustomerContent;
            InitValue = false;
        }
        field(77007; "Default Payment Gate Mode"; Enum "PTV Payment Gate Mode")
        {
            Caption = 'Default Payment Gate Mode';
            DataClassification = CustomerContent;
            InitValue = "Scheme Invoices";
        }
        field(77008; "FOC Reason Code"; Code[10])
        {
            Caption = 'FOC Reason Code';
            DataClassification = CustomerContent;
            TableRelation = "Reason Code".Code;
        }
        field(77009; "Suppress VAT on Credit Notes"; Boolean)
        {
            Caption = 'Suppress VAT on Credit Notes';
            DataClassification = CustomerContent;
        }
        field(77010; "Posted Credit Memo Nos."; Code[20])
        {
            Caption = 'Posted Credit Memo Nos.';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(77011; "Zero VAT Business Group"; Code[20])
        {
            Caption = 'Zero VAT Business Group';
            DataClassification = CustomerContent;
            TableRelation = "VAT Business Posting Group".Code;
        }
        field(77012; "Zero VAT Product Group"; Code[20])
        {
            Caption = 'Zero VAT Product Group';
            DataClassification = CustomerContent;
            TableRelation = "VAT Product Posting Group".Code;
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
    /// Gets the single rebate setup record, inserting defaults when missing.
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
