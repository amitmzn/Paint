tableextension 76045 "PTV User Setup" extends "User Setup"
{
    fields
    {
        field(76000; "PTV Store Location Code"; Code[10])
        {
            Caption = 'Store Location';
            DataClassification = CustomerContent;
            TableRelation = "PTV Fast Sales Store"."Location Code";
        }
    }
}
