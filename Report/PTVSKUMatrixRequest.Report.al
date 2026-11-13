report 76158 "PTV SKU Matrix Request"
{
    Caption = 'SKU Matrix Request';
    ProcessingOnly = true;
    UsageCategory = Tasks;
    ApplicationArea = All;

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Filters)
                {
                    Caption = 'Filters';
                    field(ProductFilter; ProductFilter)
                    {
                        ApplicationArea = All;
                        Caption = 'Product';
                        TableRelation = "PTV Paint Product".Code;
                        ToolTip = 'Specifies the products to explode. Leave blank for all unblocked products.';
                    }
                    field(ShadeFilter; ShadeFilter)
                    {
                        ApplicationArea = All;
                        Caption = 'Shade';
                        TableRelation = "PTV Shade".Code;
                        ToolTip = 'Specifies the shades to explode. Leave blank for all unblocked shades.';
                    }
                    field(PackFilter; PackFilter)
                    {
                        ApplicationArea = All;
                        Caption = 'Pack';
                        TableRelation = "PTV Pack".Code;
                        ToolTip = 'Specifies the packs to explode. Leave blank for all unblocked packs.';
                    }
                }
            }
        }
    }

    trigger OnPostReport()
    begin
        CreateBlockedSkus();
    end;

    var
        ProductFilter: Code[20];
        ShadeFilter: Code[20];
        PackFilter: Code[20];

    local procedure CreateBlockedSkus()
    var
        Product: Record "PTV Paint Product";
        Shade: Record "PTV Shade";
        Pack: Record "PTV Pack";
        Item: Record Item;
        PaintSetup: Record "PTV Paint Setup";
        InventorySetup: Record "Inventory Setup";
        NoSeries: Codeunit "No. Series";
        SeriesCode: Code[20];
    begin
        PaintSetup.GetSetup();
        SeriesCode := PaintSetup."SKU Item Nos.";
        if SeriesCode = '' then begin
            InventorySetup.Get();
            SeriesCode := InventorySetup."Item Nos.";
        end;

        Product.SetRange(Blocked, false);
        if ProductFilter <> '' then
            Product.SetRange(Code, ProductFilter);
        Shade.SetRange(Blocked, false);
        if ShadeFilter <> '' then
            Shade.SetRange(Code, ShadeFilter);
        Pack.SetRange(Blocked, false);
        if PackFilter <> '' then
            Pack.SetRange(Code, PackFilter);

        Product.SetLoadFields(Code, Description, "Specific Gravity");
        Shade.SetLoadFields(Code, Description);
        Pack.SetLoadFields(Code, Description, "Pack Size Litres");
        if not Product.FindSet() then
            exit;
        repeat
            if Shade.FindSet() then
                repeat
                    if Pack.FindSet() then
                        repeat
                            if not SkuExists(Product.Code, Shade.Code, Pack.Code) then begin
                                Item.Init();
                                Item."No." := NoSeries.GetNextNo(SeriesCode, WorkDate(), false);
                                Item.Insert(true);
                                Item.Validate(Description, CopyStr(Product.Description + ' ' + Shade.Description + ' ' + Pack.Description, 1, MaxStrLen(Item.Description)));
                                Item.Validate("PTV Product Code", Product.Code);
                                Item.Validate("PTV Shade Code", Shade.Code);
                                Item.Validate("PTV Pack Code", Pack.Code);
                                Item.Validate("PTV Item Role", Item."PTV Item Role"::"FG Paint");
                                if Product."Specific Gravity" <> 0 then
                                    Item.Validate("PTV Specific Gravity", Product."Specific Gravity");
                                Item.Modify(true);
                            end;
                        until Pack.Next() = 0;
                until Shade.Next() = 0;
        until Product.Next() = 0;
    end;

    local procedure SkuExists(ProductCode: Code[20]; ShadeCode: Code[20]; PackCode: Code[20]): Boolean
    var
        Item: Record Item;
    begin
        Item.SetCurrentKey("PTV Product Code", "PTV Shade Code", "PTV Pack Code");
        Item.SetRange("PTV Product Code", ProductCode);
        Item.SetRange("PTV Shade Code", ShadeCode);
        Item.SetRange("PTV Pack Code", PackCode);
        exit(not Item.IsEmpty());
    end;
}
