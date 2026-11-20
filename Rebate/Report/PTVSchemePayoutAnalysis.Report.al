report 77150 "PTV Scheme Payout Analysis"
{
    Caption = 'Scheme Payout & Mix Analysis';
    ApplicationArea = All;
    DefaultRenderingLayout = RDLC;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Entitlement; "PTV Scheme Entitlement")
        {
            RequestFilterFields = "Scheme Code", "Customer No.", "Period Start Date", "Period End Date", Status;
            column(EntryNo; "Entry No.") { }
            column(SchemeCode; "Scheme Code") { }
            column(CustomerNo; "Customer No.") { }
            column(CustomerName; "Customer Name") { }
            column(SchemeProductGroup; "Scheme Product Group") { }
            column(PeriodStartDate; "Period Start Date") { }
            column(PeriodEndDate; "Period End Date") { }
            column(EligibleQty; "Eligible Qty (Kg/Ltr)") { }
            column(NetSalesValue; "Net Sales Value") { }
            column(PriorYearQty; "Prior Year Qty") { }
            column(PriorYearValue; "Prior Year Value") { }
            column(GrowthPct; "Growth %") { }
            column(GrowthQualified; "Growth Qualified") { }
            column(PaymentCleared; "Payment Cleared") { }
            column(UnpaidInvoiceAmount; "Unpaid Invoice Amount") { }
            column(RewardChoice; "Reward Choice") { }
            column(TotalRebateAmount; "Total Rebate Amount") { }
            column(QualificationTier; "Qualification Tier Code") { }
            column(EstimatedFOCCost; "Estimated FOC Cost") { }
            column(FOCQuantity; "FOC Quantity") { }
            column(TripDescription; "Trip Description") { }
            column(LuxuryMixPct; "Luxury Mix %") { }
            column(PremiumMixPct; "Premium Mix %") { }
            column(BudgetMixPct; "Budget Mix %") { }
            column(Status; Status) { }
        }
    }

    rendering
    {
        layout(RDLC)
        {
            Type = RDLC;
            LayoutFile = './layout/PTVSchemePayoutAnalysis.rdlc';
            Caption = 'Scheme Payout & Mix Analysis';
        }
    }
}
