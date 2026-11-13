codeunit 77204 "PTV Scheme Entitlement Post"
{
    /// <summary>
    /// Posts finalized entitlements to Posted tables and optionally closes the scheme header.
    /// </summary>
    procedure PostEntitlements(SchemeCode: Code[20]; CloseScheme: Boolean): Integer
    var
        SchemeHdr: Record "PTV Scheme Header";
        Entitlement: Record "PTV Scheme Entitlement";
        PostedEnt: Record "PTV Posted Scheme Entitlement";
        Applied: Record "PTV Scheme Applied Entry";
        PostedApplied: Record "PTV Posted Scheme Applied";
        PostedCount: Integer;
        ClosedErr: Label 'Scheme %1 is already closed.';
        NoneReadyErr: Label 'No finalized entitlements (Credit Note Created, FOC Order Created, or Trip Fulfilled) found for scheme %1.';
    begin
        SchemeHdr.Get(SchemeCode);
        if SchemeHdr.Status = SchemeHdr.Status::Closed then
            Error(ClosedErr, SchemeCode);

        Entitlement.SetRange("Scheme Code", SchemeCode);
        Entitlement.SetFilter(
            Status, '%1|%2|%3',
            Entitlement.Status::"Credit Note Created",
            Entitlement.Status::"FOC Order Created",
            Entitlement.Status::"Trip Fulfilled");
        if not Entitlement.FindSet() then
            Error(NoneReadyErr, SchemeCode);

        repeat
            PostedEnt.Init();
            PostedEnt."Original Entry No." := Entitlement."Entry No.";
            PostedEnt."Scheme Code" := Entitlement."Scheme Code";
            PostedEnt."Scheme Line No." := Entitlement."Scheme Line No.";
            PostedEnt."Slab No." := Entitlement."Slab No.";
            PostedEnt."Customer No." := Entitlement."Customer No.";
            PostedEnt."Scheme Product Group" := Entitlement."Scheme Product Group";
            PostedEnt."Period Start Date" := Entitlement."Period Start Date";
            PostedEnt."Period End Date" := Entitlement."Period End Date";
            PostedEnt."Eligible Qty (Kg/Ltr)" := Entitlement."Eligible Qty (Kg/Ltr)";
            PostedEnt."Net Sales Value" := Entitlement."Net Sales Value";
            PostedEnt."Prior Year Qty" := Entitlement."Prior Year Qty";
            PostedEnt."Prior Year Value" := Entitlement."Prior Year Value";
            PostedEnt."Growth %" := Entitlement."Growth %";
            PostedEnt."Discount Type" := Entitlement."Discount Type";
            PostedEnt."Reward Choice" := Entitlement."Reward Choice";
            PostedEnt."Total Rebate Amount" := Entitlement."Total Rebate Amount";
            PostedEnt."FOC Item No." := Entitlement."FOC Item No.";
            PostedEnt."FOC Quantity" := Entitlement."FOC Quantity";
            PostedEnt."Trip Description" := Entitlement."Trip Description";
            PostedEnt."Credit Memo No." := Entitlement."Credit Memo No.";
            PostedEnt."FOC Sales Order No." := Entitlement."FOC Sales Order No.";
            PostedEnt.Status := PostedEnt.Status::Posted;
            PostedEnt."Posted By" := CopyStr(UserId(), 1, MaxStrLen(PostedEnt."Posted By"));
            PostedEnt."Posted Date" := CurrentDateTime();
            PostedEnt.Insert(true);

            Applied.SetRange("Entitlement Entry No.", Entitlement."Entry No.");
            if Applied.FindSet() then
                repeat
                    PostedApplied.Init();
                    PostedApplied."Posted Ent. Entry No." := PostedEnt."Entry No.";
                    PostedApplied."Scheme Code" := Applied."Scheme Code";
                    PostedApplied."Exclusion Group" := Applied."Exclusion Group";
                    PostedApplied."Customer No." := Applied."Customer No.";
                    PostedApplied."Source Document Type" := Applied."Source Document Type";
                    PostedApplied."Document No." := Applied."Document No.";
                    PostedApplied."Document Line No." := Applied."Document Line No.";
                    PostedApplied."Posting Date" := Applied."Posting Date";
                    PostedApplied."Item No." := Applied."Item No.";
                    PostedApplied.Quantity := Applied.Quantity;
                    PostedApplied."Eligible Qty (Kg/Ltr)" := Applied."Eligible Qty (Kg/Ltr)";
                    PostedApplied."Net Amount" := Applied."Net Amount";
                    PostedApplied.Insert(true);
                until Applied.Next() = 0;
            Applied.DeleteAll();

            PostedCount += 1;
        until Entitlement.Next() = 0;

        Entitlement.DeleteAll();

        if CloseScheme then begin
            SchemeHdr.Status := SchemeHdr.Status::Closed;
            SchemeHdr.Modify(true);
        end;

        exit(PostedCount);
    end;
}
