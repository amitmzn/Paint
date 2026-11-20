table 77002 "PTV Scheme Header"
{
    Caption = 'Rebate Scheme Header';
    DataClassification = CustomerContent;
    LookupPageId = "PTV Scheme List";
    DrillDownPageId = "PTV Scheme List";

    fields
    {
        field(77000; Code; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if Rec.Code <> xRec.Code then
                    Rec."No. Series" := '';
            end;
        }
        field(77001; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(77002; "Reference No."; Code[30])
        {
            Caption = 'Memo / Reference No.';
            DataClassification = CustomerContent;
        }
        field(77003; "Start Date"; Date)
        {
            Caption = 'Start Date';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                ValidateDateOrder();
            end;
        }
        field(77004; "End Date"; Date)
        {
            Caption = 'End Date';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                ValidateDateOrder();
            end;
        }
        field(77005; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(77006; "Scheme Type"; Enum "PTV Scheme Type")
        {
            Caption = 'Scheme Type';
            DataClassification = CustomerContent;
        }
        field(77007; "Evaluation Period"; Enum "PTV Evaluation Period")
        {
            Caption = 'Evaluation Period';
            DataClassification = CustomerContent;
        }
        field(77008; "Calculation Basis"; Enum "PTV Calculation Basis")
        {
            Caption = 'Calculation Basis';
            InitValue = "Net Sales Value";
            DataClassification = CustomerContent;
        }
        field(77009; Status; Enum "PTV Scheme Status")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
        }
        field(77010; "Territory Filter"; Text[100])
        {
            Caption = 'Territory Filter';
            DataClassification = CustomerContent;
            TableRelation = Territory.Code;
            ValidateTableRelation = false;
        }
        field(77011; "Location Filter"; Text[100])
        {
            Caption = 'Location / Depot Filter';
            DataClassification = CustomerContent;
            TableRelation = Location.Code;
            ValidateTableRelation = false;
        }
        field(77012; "Cust. Price Group Filter"; Text[100])
        {
            Caption = 'Customer Price Group Filter';
            DataClassification = CustomerContent;
            TableRelation = "Customer Price Group".Code;
            ValidateTableRelation = false;
        }
        field(77013; "Customer Filter"; Text[100])
        {
            Caption = 'Customer Filter';
            DataClassification = CustomerContent;
            TableRelation = Customer."No.";
            ValidateTableRelation = false;
        }
        field(77014; "Trade Channel Filter"; Enum "PTV Trade Channel")
        {
            Caption = 'Trade Channel Filter';
            DataClassification = CustomerContent;
        }
        field(77015; "Minimum Net Value"; Decimal)
        {
            Caption = 'Minimum Net Value';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(77016; "Minimum Quantity"; Decimal)
        {
            Caption = 'Minimum Quantity';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(77017; "Exclude FOC Lines"; Boolean)
        {
            Caption = 'Exclude FOC Lines';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(77018; "Special Price Handling"; Enum "PTV Special Price Handling")
        {
            Caption = 'Special Price Handling';
            DataClassification = CustomerContent;
            InitValue = "Exclude Line";
        }
        field(77019; "Require Growth Check"; Boolean)
        {
            Caption = 'Require YoY Growth Check';
            DataClassification = CustomerContent;
        }
        field(77020; "Default Min Growth %"; Decimal)
        {
            Caption = 'Default Min Growth %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
        }
        field(77021; "Growth Failure Action"; Enum "PTV Growth Failure Action")
        {
            Caption = 'Growth Failure Action';
            DataClassification = CustomerContent;
        }
        field(77022; "Payment Gate Mode"; Enum "PTV Payment Gate Mode")
        {
            Caption = 'Payment Gate Mode';
            DataClassification = CustomerContent;
            InitValue = "Scheme Invoices";
        }
        field(77023; "Exclusion Group"; Code[20])
        {
            Caption = 'Exclusion Group';
            DataClassification = CustomerContent;
        }
        field(77024; "FOC Grouping Type"; Enum "PTV FOC Grouping Type")
        {
            Caption = 'FOC Grouping Type';
            DataClassification = CustomerContent;
        }
        field(77025; "Enforce Product Mix"; Boolean)
        {
            Caption = 'Enforce Product Mix';
            DataClassification = CustomerContent;
        }
        field(77026; "Luxury Mix Target %"; Decimal)
        {
            Caption = 'Luxury Mix Target %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
        }
        field(77027; "Premium Mix Target %"; Decimal)
        {
            Caption = 'Premium Mix Target %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
        }
        field(77028; "Budget Mix Target %"; Decimal)
        {
            Caption = 'Budget & Economy Mix Target %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
        }
        field(77029; "Rebate G/L Account"; Code[20])
        {
            Caption = 'Rebate G/L Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account"."No.";
        }
        field(77030; "Provision G/L Account"; Code[20])
        {
            Caption = 'Provision G/L Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account"."No.";
        }
        field(77031; "Suppress VAT on Credit Notes"; Boolean)
        {
            Caption = 'Suppress VAT on Credit Notes';
            DataClassification = CustomerContent;
        }
        field(77032; "FOC Reason Code"; Code[10])
        {
            Caption = 'FOC Reason Code';
            DataClassification = CustomerContent;
            TableRelation = "Reason Code".Code;
        }
        field(77033; "Posted Credit Memo Nos."; Code[20])
        {
            Caption = 'Posted Credit Memo Nos.';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(77034; "Use Customer Targets"; Boolean)
        {
            Caption = 'Use Customer Targets';
            DataClassification = CustomerContent;
        }
        field(77035; "Exclude If No Target"; Boolean)
        {
            Caption = 'Exclude If No Target';
            DataClassification = CustomerContent;
        }
        field(77036; "Default Target Value"; Decimal)
        {
            Caption = 'Default Target Value';
            DataClassification = CustomerContent;
        }
        field(77037; "Created By"; Code[50])
        {
            Caption = 'Created By';
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
        }
        field(77038; "Created On"; Date)
        {
            Caption = 'Created On';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(77039; "Changed By"; Code[50])
        {
            Caption = 'Changed By';
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
        }
        field(77040; "Changed On"; Date)
        {
            Caption = 'Changed On';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(77041; "No. of Lines"; Integer)
        {
            Caption = 'No. of Lines';
            FieldClass = FlowField;
            CalcFormula = count("PTV Scheme Line" where("Scheme Code" = field(Code)));
            Editable = false;
        }
        field(77042; "No. of Slabs"; Integer)
        {
            Caption = 'No. of Slabs';
            FieldClass = FlowField;
            CalcFormula = count("PTV Scheme Slab" where("Scheme Code" = field(Code)));
            Editable = false;
        }
        field(77043; "Payment Cutoff Date"; Date)
        {
            Caption = 'Payment Cutoff Date';
            DataClassification = CustomerContent;
        }
        field(77044; "Claim Priority"; Integer)
        {
            Caption = 'Claim Priority';
            DataClassification = CustomerContent;
            MinValue = 0;
        }
        field(77045; "Require FOC Review"; Boolean)
        {
            Caption = 'Require FOC Review';
            DataClassification = CustomerContent;
        }
        field(77046; "Suppress VAT on FOC"; Boolean)
        {
            Caption = 'Suppress VAT on FOC';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
        key(Dates; "Start Date", "End Date")
        {
        }
        key(ClaimSequence; "Exclusion Group", "Claim Priority", Code)
        {
        }
    }

    trigger OnInsert()
    var
        RebateSetup: Record "PTV Rebate Setup";
        NoSeries: Codeunit "No. Series";
    begin
        RebateSetup.GetSetup();
        if Rec.Code = '' then begin
            RebateSetup.TestField("Scheme Nos.");
            Rec."No. Series" := RebateSetup."Scheme Nos.";
            Rec.Code := NoSeries.GetNextNo(Rec."No. Series");
        end;
        if Rec."Rebate G/L Account" = '' then
            Rec."Rebate G/L Account" := RebateSetup."Default Rebate G/L Account";
        if Rec."Provision G/L Account" = '' then
            Rec."Provision G/L Account" := RebateSetup."Default Provision G/L Acc.";
        if Rec."Posted Credit Memo Nos." = '' then
            Rec."Posted Credit Memo Nos." := RebateSetup."Posted Credit Memo Nos.";
        if Rec."FOC Reason Code" = '' then
            Rec."FOC Reason Code" := RebateSetup."FOC Reason Code";

        Rec."Created By" := CopyStr(UserId(), 1, MaxStrLen(Rec."Created By"));
        Rec."Created On" := Today();
    end;

    trigger OnModify()
    var
        ClosedErr: Label 'Scheme %1 is closed and cannot be modified.';
    begin
        if xRec.Status = xRec.Status::Closed then
            Error(ClosedErr, Rec.Code);
        Rec."Changed By" := CopyStr(UserId(), 1, MaxStrLen(Rec."Changed By"));
        Rec."Changed On" := Today();
    end;

    trigger OnDelete()
    var
        SchemeLine: Record "PTV Scheme Line";
        SchemeSlab: Record "PTV Scheme Slab";
        SchemeTarget: Record "PTV Scheme Customer Target";
        ClosedErr: Label 'Closed scheme %1 cannot be deleted.';
    begin
        if Rec.Status = Rec.Status::Closed then
            Error(ClosedErr, Rec.Code);

        SchemeLine.SetRange("Scheme Code", Rec.Code);
        SchemeLine.DeleteAll();
        SchemeSlab.SetRange("Scheme Code", Rec.Code);
        SchemeSlab.DeleteAll();
        SchemeTarget.SetRange("Scheme Code", Rec.Code);
        SchemeTarget.DeleteAll();
    end;

    local procedure ValidateDateOrder()
    var
        DateOrderErr: Label 'End Date cannot be earlier than Start Date.';
    begin
        if (Rec."Start Date" <> 0D) and (Rec."End Date" <> 0D) and (Rec."End Date" < Rec."Start Date") then
            Error(DateOrderErr);
    end;
}
