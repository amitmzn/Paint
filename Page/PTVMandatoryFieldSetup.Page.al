page 76064 "PTV Mandatory Field Setup"
{
    ApplicationArea = All;
    Caption = 'Mandatory Field Setup';
    PageType = List;
    SourceTable = "PTV Mandatory Field Setup";
    UsageCategory = Administration;
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Table No."; Rec."Table No.")
                {
                    ToolTip = 'Specifies the table that owns the mandatory field.';
                }
                field("Field No."; Rec."Field No.")
                {
                    ToolTip = 'Specifies the field that must be filled before approval.';
                }
                field("Field Caption"; Rec."Field Caption")
                {
                    ToolTip = 'Specifies the caption of the mandatory field.';
                }
                field("Item Role"; Rec."Item Role")
                {
                    ToolTip = 'Specifies the item role this rule applies to. Blank applies to every role.';
                }
                field(Active; Rec.Active)
                {
                    ToolTip = 'Specifies that this rule is enforced.';
                }
            }
        }
    }
}
