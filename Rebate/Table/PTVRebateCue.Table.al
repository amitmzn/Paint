table 77014 "PTV Rebate Cue"
{
    Caption = 'Rebate & Scheme Cue';
    DataClassification = CustomerContent;

    fields
    {
        field(77000; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = SystemMetadata;
        }
        field(77001; "Open Schemes"; Integer)
        {
            Caption = 'Open Schemes';
            FieldClass = FlowField;
            CalcFormula = count("PTV Scheme Header" where(Status = const(Open)));
            Editable = false;
        }
        field(77002; "Released Schemes"; Integer)
        {
            Caption = 'Released Schemes';
            FieldClass = FlowField;
            CalcFormula = count("PTV Scheme Header" where(Status = const(Released)));
            Editable = false;
        }
        field(77003; "Open Entitlements"; Integer)
        {
            Caption = 'Open Entitlements';
            FieldClass = FlowField;
            CalcFormula = count("PTV Scheme Entitlement" where(Status = const(Open)));
            Editable = false;
        }
        field(77004; "Approved Entitlements"; Integer)
        {
            Caption = 'Approved Entitlements';
            FieldClass = FlowField;
            CalcFormula = count("PTV Scheme Entitlement" where(Status = const(Approved)));
            Editable = false;
        }
        field(77005; "Posted Entitlements"; Integer)
        {
            Caption = 'Posted Entitlements';
            FieldClass = FlowField;
            CalcFormula = count("PTV Posted Scheme Entitlement");
            Editable = false;
        }
        field(77006; "Open Subsidies"; Integer)
        {
            Caption = 'Open Subsidies';
            FieldClass = FlowField;
            CalcFormula = count("PTV Subsidy Header" where(Status = const(Open)));
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}
