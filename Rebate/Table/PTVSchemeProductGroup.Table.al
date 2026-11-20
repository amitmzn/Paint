table 77001 "PTV Scheme Product Group"
{
    Caption = 'Scheme Product Group';
    DataClassification = CustomerContent;
    LookupPageId = "PTV Scheme Product Groups";
    DrillDownPageId = "PTV Scheme Product Groups";

    fields
    {
        field(77000; Code; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(77001; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(77002; "Product Segment"; Enum "PTV Product Segment")
        {
            Caption = 'Product Segment';
            DataClassification = CustomerContent;
        }
        field(77003; "Rebate Measure"; Enum "PTV Rebate Measure")
        {
            Caption = 'Rebate Measure';
            DataClassification = CustomerContent;
        }
        field(77004; "Default Min Growth %"; Decimal)
        {
            Caption = 'Default Min Growth %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
            MinValue = 0;
        }
        field(77005; Blocked; Boolean)
        {
            Caption = 'Blocked';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        Member: Record "PTV Scheme Prod. Grp. Member";
    begin
        Member.SetRange("Group Code", Rec.Code);
        Member.DeleteAll();
    end;
}
