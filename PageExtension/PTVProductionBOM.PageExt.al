pageextension 76107 "PTV Production BOM" extends "Production BOM"
{
    layout
    {
        addlast(Content)
        {
            part(PTVBOMInstructions; "PTV BOM Instructions")
            {
                ApplicationArea = All;
                Caption = 'Instructions';
                SubPageLink = "BOM No." = field("No."), "Version Code" = const('');
            }
        }
    }
}
