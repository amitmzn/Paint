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
    /// Returns the quantity per of the kilogram unit so that one litre equals specific gravity kilograms.
    /// </summary>
    /// <param name="SpecificGravity">Kilograms per litre.</param>
    /// <returns>Base-unit quantity represented by one kilogram.</returns>
    procedure KgQtyPerFromSpecificGravity(SpecificGravity: Decimal): Decimal
    begin
        if SpecificGravity = 0 then
            exit(0);
        exit(1 / SpecificGravity);
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
    /// Converts a quantity in the given unit of measure to litres. The base unit of paint is LTR.
    /// </summary>
    /// <param name="ItemNo">Item number.</param>
    /// <param name="UnitOfMeasureCode">Unit of measure of the quantity.</param>
    /// <param name="Quantity">Quantity in that unit of measure.</param>
    /// <returns>Quantity in litres.</returns>
    procedure LineQuantityToLitres(ItemNo: Code[20]; UnitOfMeasureCode: Code[10]; Quantity: Decimal): Decimal
    var
        Item: Record Item;
        ItemUnitOfMeasure: Record "Item Unit of Measure";
    begin
        if (ItemNo = '') or (Quantity = 0) then
            exit(0);
        Item.SetLoadFields("Base Unit of Measure");
        if not Item.Get(ItemNo) then
            exit(0);
        if (UnitOfMeasureCode = '') or (UnitOfMeasureCode = Item."Base Unit of Measure") then
            exit(QuantityInBaseToLitres(Item."Base Unit of Measure", Quantity));

        ItemUnitOfMeasure.SetLoadFields("Qty. per Unit of Measure");
        if ItemUnitOfMeasure.Get(ItemNo, UnitOfMeasureCode) then
            exit(QuantityInBaseToLitres(Item."Base Unit of Measure", Quantity * ItemUnitOfMeasure."Qty. per Unit of Measure"));
        exit(0);
    end;

    /// <summary>
    /// Ensures the litre, kilogram and container units of measure exist for the item pack.
    /// </summary>
    /// <param name="Item">Item whose pack and specific gravity drive the units.</param>
    procedure MaintainItemUOMFromPack(var Item: Record Item)
    var
        Pack: Record "PTV Pack";
    begin
        EnsureUnitOfMeasure('LTR', 'Litre');
        EnsureUnitOfMeasure('KG', 'Kilogram');
        if Item."Base Unit of Measure" = '' then
            Item."Base Unit of Measure" := 'LTR';
        EnsureItemUnitOfMeasure(Item."No.", 'LTR', 1);
        MaintainKgUom(Item);
        if Item."PTV Pack Code" = '' then
            exit;
        Pack.SetLoadFields("Pack Size Litres", "Container UOM Code");
        if not Pack.Get(Item."PTV Pack Code") then
            exit;
        if Pack."Container UOM Code" <> '' then
            EnsureItemUnitOfMeasure(Item."No.", Pack."Container UOM Code", Pack."Pack Size Litres");
    end;

    /// <summary>
    /// Sets the kilogram unit so that one litre equals the item specific gravity in kilograms.
    /// </summary>
    /// <param name="Item">Item that owns the specific gravity.</param>
    procedure MaintainKgUom(var Item: Record Item)
    begin
        if Item."PTV Specific Gravity" = 0 then
            exit;
        EnsureUnitOfMeasure('KG', 'Kilogram');
        EnsureItemUnitOfMeasure(Item."No.", 'KG', KgQtyPerFromSpecificGravity(Item."PTV Specific Gravity"));
    end;

    local procedure QuantityInBaseToLitres(BaseUnitOfMeasure: Code[10]; QuantityBase: Decimal): Decimal
    begin
        if BaseUnitOfMeasure = 'LTR' then
            exit(QuantityBase);
        exit(QuantityBase);
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
        ItemUnitOfMeasure.Insert(true);
        ItemUnitOfMeasure.Validate("Qty. per Unit of Measure", QtyPer);
        ItemUnitOfMeasure.Modify(true);
    end;
}
