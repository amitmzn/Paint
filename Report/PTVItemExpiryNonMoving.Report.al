report 76153 "PTV Item Expiry & Non-Moving"
{
    Caption = 'Item Expiry and Non-Moving';
    ApplicationArea = All;
    DefaultRenderingLayout = RDLC;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(ItemLedgerEntry; "Item Ledger Entry")
        {
            RequestFilterFields = "Item No.", "Location Code", "Lot No.";
            DataItemTableView = where("Remaining Quantity" = filter('>0'));
            column(ItemNo; "Item No.") { }
            column(LotNo; "Lot No.") { }
            column(LocationCode; "Location Code") { }
            column(RemainingQty; "Remaining Quantity") { }
            column(PostingDate; "Posting Date") { }
            column(ExpirationDate; "Expiration Date") { }
            column(AgeBucket; AgeBucket) { }
            column(ExpiryBucket; ExpiryBucket) { }

            trigger OnAfterGetRecord()
            var
                Age: Integer;
            begin
                Age := WorkDate() - "Posting Date";
                AgeBucket := Bucket(Age);
                if "Expiration Date" = 0D then
                    ExpiryBucket := 'None'
                else
                    ExpiryBucket := Bucket("Expiration Date" - WorkDate());
            end;
        }
    }

    rendering
    {
        layout(RDLC)
        {
            Type = RDLC;
            LayoutFile = './layout/PTVItemExpiryNonMoving.rdlc';
            Caption = 'Item Expiry and Non-Moving';
        }
    }

    var
        AgeBucket: Text[10];
        ExpiryBucket: Text[10];

    local procedure Bucket(Days: Integer): Text[10]
    begin
        if Days <= 30 then
            exit('30');
        if Days <= 60 then
            exit('60');
        exit('90+');
    end;
}
