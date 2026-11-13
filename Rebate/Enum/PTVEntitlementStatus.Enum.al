enum 77265 "PTV Entitlement Status"
{
    Extensible = true;
    Caption = 'Entitlement Status';

    value(0; Open) { Caption = 'Open'; }
    value(1; "Pending Approval") { Caption = 'Pending Approval'; }
    value(2; Approved) { Caption = 'Approved'; }
    value(3; Rejected) { Caption = 'Rejected'; }
    value(4; "Credit Note Created") { Caption = 'Credit Note Created'; }
    value(5; "FOC Order Created") { Caption = 'FOC Order Created'; }
    value(6; "Trip Fulfilled") { Caption = 'Trip Fulfilled'; }
    value(7; "Journal Created") { Caption = 'Journal Created'; }
    value(8; Posted) { Caption = 'Posted'; }
}
