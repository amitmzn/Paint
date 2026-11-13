table 76009 "PTV Fast Sales Cue"
{
    Caption = 'Fast Sales Cue';
    DataClassification = CustomerContent;

    fields
    {
        field(76000; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = SystemMetadata;
        }
        field(76001; "Open Invoices"; Integer)
        {
            Caption = 'Open Invoices';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count("Sales Header" where("Document Type" = const(Invoice),
                                                      "PTV Fast Sales" = const(true),
                                                      "Responsibility Center" = field("Resp. Ctr. Filter")));
        }
        field(76002; "Posted Today"; Integer)
        {
            Caption = 'Posted Today';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count("Sales Invoice Header" where("PTV Fast Sales" = const(true),
                                                              "Posting Date" = field("Date Filter"),
                                                              "Responsibility Center" = field("Resp. Ctr. Filter")));
        }
        field(76003; "Resp. Ctr. Filter"; Text[100])
        {
            Caption = 'Responsibility Centre Filter';
            FieldClass = FlowFilter;
        }
        field(76004; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
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
