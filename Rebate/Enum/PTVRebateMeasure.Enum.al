enum 77257 "PTV Rebate Measure"
{
    Extensible = true;
    Caption = 'Rebate Measure';

    value(0; Auto) { Caption = 'Auto (Litres if Liquid else Kg)'; }
    value(1; Litres) { Caption = 'Litres'; }
    value(2; Kilograms) { Caption = 'Kilograms'; }
    value(3; "Base UOM") { Caption = 'Base UOM'; }
}
