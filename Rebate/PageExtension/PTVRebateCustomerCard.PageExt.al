pageextension 77100 "PTV Rebate Customer Card" extends "Customer Card"
{
    layout
    {
        addlast(General)
        {
            group("PTV Rebate Applicability")
            {
                Caption = 'Scheme & Rebate Applicability';

                field("PTV Trade Channel"; Rec."PTV Trade Channel")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the customer belongs to Trade, Institutional, Project, or Export channel.';
                }
                field("PTV Tie-Up Discount Opted"; Rec."PTV Tie-Up Discount Opted")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the dealer opted for tie-up discounts / special prices.';
                }
                field("PTV Depot Location Code"; Rec."PTV Depot Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the depot / location code associated with this customer.';
                }
            }
        }
    }
}
