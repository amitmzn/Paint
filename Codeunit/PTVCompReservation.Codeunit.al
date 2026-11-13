codeunit 76207 "PTV Comp Reservation"
{
    /// <summary>
    /// Reserves remaining component demand for a production order. Called only when the setup flag is on.
    /// </summary>
    /// <param name="ProdOrder">Released production order.</param>
    procedure AutoReserveComponents(ProdOrder: Record "Production Order")
    var
        ProdOrderComponent: Record "Prod. Order Component";
        ReservationManagement: Codeunit "Reservation Management";
        FullAutoReservation: Boolean;
    begin
        ProdOrderComponent.SetRange(Status, ProdOrder.Status);
        ProdOrderComponent.SetRange("Prod. Order No.", ProdOrder."No.");
        ProdOrderComponent.SetFilter("Remaining Qty. (Base)", '>0');
        if not ProdOrderComponent.FindSet() then
            exit;
        repeat
            ReservationManagement.SetReservSource(ProdOrderComponent);
            ReservationManagement.AutoReserve(FullAutoReservation, ProdOrderComponent.Description, ProdOrderComponent."Due Date", ProdOrderComponent."Remaining Quantity", ProdOrderComponent."Remaining Qty. (Base)");
        until ProdOrderComponent.Next() = 0;
    end;
}
