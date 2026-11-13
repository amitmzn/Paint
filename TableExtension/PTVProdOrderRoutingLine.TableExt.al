tableextension 76040 "PTV Prod. Order Routing Line" extends "Prod. Order Routing Line"
{
    fields
    {
        field(76000; "PTV QC Checkpoint"; Boolean)
        {
            Caption = 'QC Checkpoint';
            DataClassification = CustomerContent;
        }
    }
}
