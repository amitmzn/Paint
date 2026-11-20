codeunit 76202 "PTV UOM Mgt"
{
    /// <summary>
    /// Converts a volume in litres to kilograms using specific gravity.
    /// </summary>
    /// <param name="VolumeLitres">Volume in litres.</param>
    /// <param name="SpecificGravity">Kilograms per litre.</param>
    /// <returns>Weight in kilograms.</returns>
    procedure WeightFromVolume(VolumeLitres: Decimal; SpecificGravity: Decimal): Decimal
    begin
        exit(VolumeLitres * SpecificGravity);
    end;

    /// <summary>
    /// Converts a weight in kilograms to litres using specific gravity.
    /// </summary>
    /// <param name="WeightKg">Weight in kilograms.</param>
    /// <param name="SpecificGravity">Kilograms per litre.</param>
    /// <returns>Volume in litres. Returns zero when specific gravity is zero.</returns>
    procedure VolumeFromWeight(WeightKg: Decimal; SpecificGravity: Decimal): Decimal
    begin
        if SpecificGravity = 0 then
            exit(0);
        exit(WeightKg / SpecificGravity);
    end;

    /// <summary>
    /// Returns the quantity per of the kilogram unit from kilograms per base unit.
    /// </summary>
    /// <param name="KilogramsPerBase">Kilograms per inventory base unit.</param>
    /// <returns>Base-unit quantity represented by one kilogram.</returns>
    procedure KgQtyPerFromBaseWeight(KilogramsPerBase: Decimal): Decimal
    begin
        if KilogramsPerBase = 0 then
            exit(0);
        exit(1 / KilogramsPerBase);
    end;

    /// <summary>
    /// Reads specific gravity from the item.
    /// </summary>
    /// <param name="ItemNo">Item number.</param>
    /// <returns>Specific gravity, or zero when the item does not exist.</returns>
    procedure GetSpecificGravity(ItemNo: Code[20]): Decimal
    var
        Item: Record Item;
    begin
        Item.SetLoadFields("PTV Specific Gravity");
        if Item.Get(ItemNo) then
            exit(Item."PTV Specific Gravity");
    end;

    /// <summary>
    /// Returns the volume of one inventory base unit. A zero result means no litre conversion is configured.
    /// </summary>
    procedure LitresPerBaseUnit(ItemNo: Code[20]): Decimal
    var
        Item: Record Item;
    begin
        Item.SetLoadFields("Base Unit of Measure", "PTV Pack Code", "PTV Specific Gravity");
        if Item.Get(ItemNo) then
            exit(GetLitresPerBaseUnit(Item));
    end;

    procedure PostingLitresPerBaseUnit(ItemNo: Code[20]): Decimal
    var
        Item: Record Item;
        LitresPerBase: Decimal;
        MissingConversionErr: Label 'Item %1 has no litre conversion. Configure the pack or the LTR item unit of measure before posting.', Comment = '%1 = item number';
    begin
        Item.SetLoadFields("Base Unit of Measure", "PTV Pack Code", "PTV Specific Gravity", "PTV Item Role");
        if not Item.Get(ItemNo) then
            exit(0);
        LitresPerBase := GetLitresPerBaseUnit(Item);
        if (LitresPerBase <= 0) and (Item."PTV Item Role" = Item."PTV Item Role"::"FG Paint") then
            Error(MissingConversionErr, ItemNo);
        exit(LitresPerBase);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", OnBeforeInsertItemLedgEntry, '', false, false)]
    local procedure SnapshotLedgerLitres(var ItemLedgerEntry: Record "Item Ledger Entry"; ItemJournalLine: Record "Item Journal Line"; TransferItem: Boolean; OldItemLedgEntry: Record "Item Ledger Entry"; ItemJournalLineOrigin: Record "Item Journal Line")
    begin
        if TransferItem and (OldItemLedgEntry."Item No." = ItemLedgerEntry."Item No.") then
            ItemLedgerEntry."PTV Litres per Base Unit" := OldItemLedgEntry."PTV Litres per Base Unit";
        if (ItemLedgerEntry."PTV Litres per Base Unit" <= 0) and (ItemJournalLine."Applies-from Entry" <> 0) then
            if OldItemLedgEntry.Get(ItemJournalLine."Applies-from Entry") then
                if OldItemLedgEntry."Item No." = ItemLedgerEntry."Item No." then
                    ItemLedgerEntry."PTV Litres per Base Unit" := OldItemLedgEntry."PTV Litres per Base Unit";
        if ItemLedgerEntry."PTV Litres per Base Unit" <= 0 then
            ItemLedgerEntry."PTV Litres per Base Unit" := PostingLitresPerBaseUnit(ItemLedgerEntry."Item No.");
        ItemLedgerEntry."PTV Quantity Litres" := ItemLedgerEntry.Quantity * ItemLedgerEntry."PTV Litres per Base Unit";
    end;

    procedure CheckPostingLitreUOM(ItemNo: Code[20]; UnitOfMeasureCode: Code[10]; QtyPerUOM: Decimal; LitresPerBase: Decimal)
    var
        ConversionErr: Label 'The LTR unit of measure on item %1 does not match the paint pack conversion. Refresh Paint Units of Measure on the Item Card and reselect the unit on the document.', Comment = '%1 = item number';
    begin
        if (UnitOfMeasureCode = 'LTR') and (LitresPerBase > 0) and (Round(QtyPerUOM, 0.00001) <> Round(1 / LitresPerBase, 0.00001)) then
            Error(ConversionErr, ItemNo);
    end;

    /// <summary>
    /// Converts the base quantity to litres, with a fallback for lines entered directly in litres.
    /// </summary>
    procedure TransactionLitres(UnitOfMeasureCode: Code[10]; Quantity: Decimal; QuantityBase: Decimal; LitresPerBase: Decimal): Decimal
    begin
        if LitresPerBase > 0 then
            exit(QuantityBase * LitresPerBase);
        if UnitOfMeasureCode = 'LTR' then
            exit(Quantity);
    end;

    procedure PostedInvoiceLitres(Line: Record "Sales Invoice Line"): Decimal
    begin
        if Line."PTV Litres per Base Unit" > 0 then
            exit(Line."PTV Quantity Litres");
        if Line."Unit of Measure Code" = 'LTR' then
            exit(Line.Quantity);
        exit(Line."Quantity (Base)" * LitresPerBaseUnit(Line."No."));
    end;

    procedure PostedCreditMemoLitres(Line: Record "Sales Cr.Memo Line"): Decimal
    begin
        if Line."PTV Litres per Base Unit" > 0 then
            exit(Line."PTV Quantity Litres");
        if Line."Unit of Measure Code" = 'LTR' then
            exit(Line.Quantity);
        exit(Line."Quantity (Base)" * LitresPerBaseUnit(Line."No."));
    end;

    procedure PostedShipmentLitres(Line: Record "Sales Shipment Line"): Decimal
    begin
        if Line."PTV Litres per Base Unit" > 0 then
            exit(Line."PTV Quantity Litres");
        if Line."Unit of Measure Code" = 'LTR' then
            exit(Line.Quantity);
        exit(Line."Quantity (Base)" * LitresPerBaseUnit(Line."No."));
    end;

    procedure PostedLedgerLitres(Entry: Record "Item Ledger Entry"): Decimal
    begin
        if Entry."PTV Litres per Base Unit" > 0 then
            exit(Entry."PTV Quantity Litres");
        exit(Entry.Quantity * LedgerLitresPerBase(Entry));
    end;

    procedure LedgerLitresPerBase(Entry: Record "Item Ledger Entry"): Decimal
    begin
        if Entry."PTV Litres per Base Unit" > 0 then
            exit(Entry."PTV Litres per Base Unit");
        if (Entry."Unit of Measure Code" = 'LTR') and (Entry."Qty. per Unit of Measure" > 0) then
            exit(1 / Entry."Qty. per Unit of Measure");
        exit(LitresPerBaseUnit(Entry."Item No."));
    end;

    procedure MaintainItemUOMFromPack(var Item: Record Item)
    var
        Pack: Record "PTV Pack";
        LitresPerBase: Decimal;
        MissingConversionErr: Label 'Define the LTR conversion for base unit %1 before assigning this pack.', Comment = '%1 = item base unit of measure';
    begin
        if not Pack.Get(Item."PTV Pack Code") then
            exit;
        Pack.TestField("Pack Size Litres");
        EnsureUnitOfMeasure('LTR', 'Litre');
        if Item."Base Unit of Measure" = '' then
            if (Item."PTV Item Role" = Item."PTV Item Role"::"FG Paint") and (Pack."Container UOM Code" <> '') then
                Item.Validate("Base Unit of Measure", Pack."Container UOM Code")
            else
                Item.Validate("Base Unit of Measure", 'LTR');

        LitresPerBase := GetLitresPerBaseUnit(Item);
        if LitresPerBase <= 0 then
            Error(MissingConversionErr, Item."Base Unit of Measure");
        EnsureItemUnitOfMeasure(Item."No.", 'LTR', 1 / LitresPerBase);
        if (Pack."Container UOM Code" <> '') and (Pack."Container UOM Code" <> 'LTR') and (Pack."Container UOM Code" <> 'KG') then
            EnsureItemUnitOfMeasure(Item."No.", Pack."Container UOM Code", Pack."Pack Size Litres" / LitresPerBase);
        MaintainKgUom(Item);
    end;

    procedure MaintainKgUom(var Item: Record Item)
    var
        LitresPerBase: Decimal;
    begin
        if (Item."PTV Specific Gravity" <= 0) or (Item."Base Unit of Measure" = '') then
            exit;
        LitresPerBase := GetLitresPerBaseUnit(Item);
        if LitresPerBase <= 0 then
            exit;
        EnsureUnitOfMeasure('KG', 'Kilogram');
        EnsureItemUnitOfMeasure(Item."No.", 'KG', KgQtyPerFromBaseWeight(Item."PTV Specific Gravity" * LitresPerBase));
    end;

    local procedure GetLitresPerBaseUnit(Item: Record Item): Decimal
    var
        Pack: Record "PTV Pack";
        ItemUnitOfMeasure: Record "Item Unit of Measure";
    begin
        case Item."Base Unit of Measure" of
            '':
                exit(0);
            'LTR':
                exit(1);
            'KG':
                exit(VolumeFromWeight(1, Item."PTV Specific Gravity"));
        end;

        Pack.SetLoadFields("Container UOM Code", "Pack Size Litres");
        if Pack.Get(Item."PTV Pack Code") then
            if (Pack."Container UOM Code" <> '') and (Pack."Pack Size Litres" > 0) then begin
                if Pack."Container UOM Code" = Item."Base Unit of Measure" then
                    exit(Pack."Pack Size Litres");
                ItemUnitOfMeasure.SetLoadFields("Qty. per Unit of Measure");
                if ItemUnitOfMeasure.Get(Item."No.", Pack."Container UOM Code") then
                    if ItemUnitOfMeasure."Qty. per Unit of Measure" > 0 then
                        exit(Pack."Pack Size Litres" / ItemUnitOfMeasure."Qty. per Unit of Measure");
            end;

        ItemUnitOfMeasure.SetLoadFields("Qty. per Unit of Measure");
        if ItemUnitOfMeasure.Get(Item."No.", 'LTR') then
            if ItemUnitOfMeasure."Qty. per Unit of Measure" > 0 then
                exit(1 / ItemUnitOfMeasure."Qty. per Unit of Measure");
    end;

    local procedure EnsureUnitOfMeasure(UomCode: Code[10]; Description: Text[50])
    var
        UnitOfMeasure: Record "Unit of Measure";
    begin
        if UnitOfMeasure.Get(UomCode) then
            exit;
        UnitOfMeasure.Init();
        UnitOfMeasure.Code := UomCode;
        UnitOfMeasure.Description := Description;
        UnitOfMeasure.Insert(true);
    end;

    local procedure EnsureItemUnitOfMeasure(ItemNo: Code[20]; UomCode: Code[10]; QtyPer: Decimal)
    var
        ItemUnitOfMeasure: Record "Item Unit of Measure";
    begin
        if ItemNo = '' then
            exit;
        if ItemUnitOfMeasure.Get(ItemNo, UomCode) then begin
            if ItemUnitOfMeasure."Qty. per Unit of Measure" = QtyPer then
                exit;
            ItemUnitOfMeasure.Validate("Qty. per Unit of Measure", QtyPer);
            ItemUnitOfMeasure.Modify(true);
            exit;
        end;
        ItemUnitOfMeasure.Init();
        ItemUnitOfMeasure."Item No." := ItemNo;
        ItemUnitOfMeasure.Code := UomCode;
        ItemUnitOfMeasure.Validate("Qty. per Unit of Measure", QtyPer);
        ItemUnitOfMeasure.Insert(true);
    end;
}
