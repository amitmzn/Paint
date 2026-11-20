table 77007 "PTV Scheme Entitlement"
{
    Caption = 'Scheme Entitlement';
    DataClassification = CustomerContent;

    fields
    {
        field(77000; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
            DataClassification = CustomerContent;
        }
        field(77001; "Scheme Code"; Code[20])
        {
            Caption = 'Scheme Code';
            DataClassification = CustomerContent;
            TableRelation = "PTV Scheme Header".Code;
        }
        field(77002; "Scheme Line No."; Integer)
        {
            Caption = 'Scheme Line No.';
            DataClassification = CustomerContent;
        }
        field(77003; "Slab No."; Integer)
        {
            Caption = 'Slab No.';
            DataClassification = CustomerContent;
        }
        field(77004; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer."No.";
        }
        field(77005; "Customer Name"; Text[100])
        {
            Caption = 'Customer Name';
            FieldClass = FlowField;
            CalcFormula = lookup(Customer.Name where("No." = field("Customer No.")));
            Editable = false;
        }
        field(77006; "Scheme Description"; Text[100])
        {
            Caption = 'Scheme Description';
            FieldClass = FlowField;
            CalcFormula = lookup("PTV Scheme Header".Description where(Code = field("Scheme Code")));
            Editable = false;
        }
        field(77007; "Scheme Product Group"; Code[20])
        {
            Caption = 'Scheme Product Group';
            DataClassification = CustomerContent;
            TableRelation = "PTV Scheme Product Group".Code;
        }
        field(77008; "Period Start Date"; Date)
        {
            Caption = 'Period Start Date';
            DataClassification = CustomerContent;
        }
        field(77009; "Period End Date"; Date)
        {
            Caption = 'Period End Date';
            DataClassification = CustomerContent;
        }
        field(77010; "Calculation Date"; Date)
        {
            Caption = 'Calculation Date';
            DataClassification = CustomerContent;
        }
        field(77011; "Sales Quantity"; Decimal)
        {
            Caption = 'Sales Quantity';
            DataClassification = CustomerContent;
        }
        field(77012; "Sales Volume Litres"; Decimal)
        {
            Caption = 'Sales Volume (Litres)';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 4;
        }
        field(77013; "Sales Weight Kg"; Decimal)
        {
            Caption = 'Sales Weight (Kg)';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 4;
        }
        field(77014; "Eligible Qty (Kg/Ltr)"; Decimal)
        {
            Caption = 'Eligible Qty (Kg/Ltr)';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 4;
        }
        field(77015; "Gross Sales Value"; Decimal)
        {
            Caption = 'Gross Sales Value';
            DataClassification = CustomerContent;
        }
        field(77016; "Net Sales Value"; Decimal)
        {
            Caption = 'Net Sales Value';
            DataClassification = CustomerContent;
        }
        field(77017; "Prior Year Qty"; Decimal)
        {
            Caption = 'Prior Year Qty';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 4;
        }
        field(77018; "Prior Year Value"; Decimal)
        {
            Caption = 'Prior Year Value';
            DataClassification = CustomerContent;
        }
        field(77019; "Growth %"; Decimal)
        {
            Caption = 'Growth %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
        }
        field(77020; "Growth Qualified"; Boolean)
        {
            Caption = 'Growth Qualified';
            DataClassification = CustomerContent;
        }
        field(77021; "Payment Cleared"; Boolean)
        {
            Caption = 'Payment Cleared';
            DataClassification = CustomerContent;
        }
        field(77022; "Unpaid Invoice Amount"; Decimal)
        {
            Caption = 'Unpaid Invoice Amount';
            DataClassification = CustomerContent;
        }
        field(77023; "Discount Type"; Enum "PTV Rebate Discount Type")
        {
            Caption = 'Reward / Discount Type';
            DataClassification = CustomerContent;
        }
        field(77024; "Reward Choice"; Enum "PTV Reward Choice")
        {
            Caption = 'Reward Choice';
            DataClassification = CustomerContent;
        }
        field(77025; "Rebate %"; Decimal)
        {
            Caption = 'Rebate %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 4;
        }
        field(77026; "Rate per Unit"; Decimal)
        {
            Caption = 'Rate per Unit';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 4;
        }
        field(77027; "Rebate Amount"; Decimal)
        {
            Caption = 'Base Rebate Amount';
            DataClassification = CustomerContent;
        }
        field(77028; "Incremental Bonus Amount"; Decimal)
        {
            Caption = 'Incremental Bonus Amount';
            DataClassification = CustomerContent;
        }
        field(77029; "Total Rebate Amount"; Decimal)
        {
            Caption = 'Total Rebate Amount';
            DataClassification = CustomerContent;
        }
        field(77030; "FOC Item No."; Code[20])
        {
            Caption = 'FOC Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item."No.";
        }
        field(77031; "FOC Unit of Measure"; Code[10])
        {
            Caption = 'FOC Unit of Measure';
            DataClassification = CustomerContent;
            TableRelation = "Unit of Measure".Code;
        }
        field(77032; "FOC Quantity"; Decimal)
        {
            Caption = 'FOC Quantity';
            DataClassification = CustomerContent;
        }
        field(77033; "Trip Description"; Text[100])
        {
            Caption = 'Trip Option Description';
            DataClassification = CustomerContent;
        }
        field(77034; "Luxury Mix %"; Decimal)
        {
            Caption = 'Luxury Mix %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
        }
        field(77035; "Premium Mix %"; Decimal)
        {
            Caption = 'Premium Mix %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
        }
        field(77036; "Budget Mix %"; Decimal)
        {
            Caption = 'Budget & Economy Mix %';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 2;
        }
        field(77037; Status; Enum "PTV Entitlement Status")
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
        }
        field(77038; "Qualification Tier Code"; Code[20])
        {
            Caption = 'Qualification Tier Code';
            DataClassification = CustomerContent;
            TableRelation = "PTV Qualification Tier".Code;
        }
        field(77039; "Credit Memo No."; Code[20])
        {
            Caption = 'Credit Memo No.';
            DataClassification = CustomerContent;
        }
        field(77040; "FOC Sales Order No."; Code[20])
        {
            Caption = 'FOC Sales Order No.';
            DataClassification = CustomerContent;
        }
        field(77041; "Journal Document No."; Code[20])
        {
            Caption = 'Journal Document No.';
            DataClassification = CustomerContent;
        }
        field(77042; "Approved By"; Code[50])
        {
            Caption = 'Approved By';
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
        }
        field(77043; "Approved On"; DateTime)
        {
            Caption = 'Approved On';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(77044; "Rejection Reason"; Text[250])
        {
            Caption = 'Notes / Disqualification Reason';
            DataClassification = CustomerContent;
        }
        field(77045; "FOC Reviewed By"; Code[50])
        {
            Caption = 'FOC Reviewed By';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(77046; "FOC Reviewed On"; DateTime)
        {
            Caption = 'FOC Reviewed On';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(77047; "Estimated FOC Cost"; Decimal)
        {
            Caption = 'Estimated FOC Cost (LCY)';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(SchemeCustPeriod; "Scheme Code", "Customer No.", "Period Start Date", "Period End Date", "Scheme Line No.")
        {
        }
        key(StatusKey; "Scheme Code", Status)
        {
        }
    }
}
