codeunit 76209 "PTV Output Valuation Date"
{
    /// <summary>
    /// Aligns an output value entry valuation date to the latest consumption valuation date of the same production order.
    /// Statutory rationale: where inventory law requires the output to be valued on the date the inputs were consumed,
    /// the output value entry must not take a later posting date than those consumptions. The setup flag defaults to off
    /// and this subscriber does nothing unless that flag is on.
    /// OnBeforePostOutput on Item Jnl.-Post Line is obsolete from application 27.0, so the valuation date is set on
    /// OnBeforeInsertValueEntry, which still receives the value entry before it is inserted.
    /// </summary>
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", OnBeforeInsertValueEntry, '', false, false)]
    local procedure AlignOutputValuationDate(var ValueEntry: Record "Value Entry"; ItemJournalLine: Record "Item Journal Line"; var ItemLedgerEntry: Record "Item Ledger Entry"; var ValueEntryNo: Integer; var InventoryPostingToGL: Codeunit "Inventory Posting To G/L"; CalledFromAdjustment: Boolean; var OldItemLedgEntry: Record "Item Ledger Entry"; var Item: Record Item; TransferItem: Boolean; var GlobalValueEntry: Record "Value Entry")
    var
        PaintSetup: Record "PTV Paint Setup";
        ConsumptionValueEntry: Record "Value Entry";
        MaxValuationDate: Date;
    begin
        if ItemJournalLine."Entry Type" <> ItemJournalLine."Entry Type"::Output then
            exit;
        if ItemJournalLine."Order No." = '' then
            exit;
        PaintSetup.SetLoadFields("Align Output ValDate");
        PaintSetup.GetSetup();
        if not PaintSetup."Align Output ValDate" then
            exit;

        ConsumptionValueEntry.SetRange("Order Type", ConsumptionValueEntry."Order Type"::Production);
        ConsumptionValueEntry.SetRange("Order No.", ItemJournalLine."Order No.");
        ConsumptionValueEntry.SetRange("Item Ledger Entry Type", ConsumptionValueEntry."Item Ledger Entry Type"::Consumption);
        ConsumptionValueEntry.SetLoadFields("Valuation Date");
        if not ConsumptionValueEntry.FindSet() then
            exit;
        repeat
            if ConsumptionValueEntry."Valuation Date" > MaxValuationDate then
                MaxValuationDate := ConsumptionValueEntry."Valuation Date";
        until ConsumptionValueEntry.Next() = 0;
        if MaxValuationDate <> 0D then
            ValueEntry."Valuation Date" := MaxValuationDate;
    end;
}
