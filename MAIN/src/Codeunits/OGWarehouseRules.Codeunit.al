codeunit 71013 "OG Warehouse Rules" implements "OG Rule Provider"
{
    procedure OGEvaluate(OGRuleSetup: Record "OG Rule Setup"; OGRunId: Guid; OGRunAt: DateTime)
    var
        OGWhseShipmentHeader: Record "Warehouse Shipment Header";
        OGExceptionEngine: Codeunit "OG Exception Engine";
        OGCutoffDateTime: DateTime;
        OGFingerprint: Text[250];
        OGDescription: Text[250];
        OGDetails: Text[2048];
        OGRecommendation: Text[250];
    begin
        if OGRuleSetup."OG Code" <> 'WHSE-SHIPMENT-STUCK' then
            exit;

        OGCutoffDateTime := CreateDateTime(Today() - OGRuleSetup."OG Threshold Days", 000000T);
        OGWhseShipmentHeader.SetFilter(SystemCreatedAt, '<=%1', OGCutoffDateTime);

        if not OGWhseShipmentHeader.FindSet() then
            exit;

        repeat
            OGFingerprint := CopyStr(StrSubstNo('WHSESHIP|%1', OGWhseShipmentHeader."No."), 1, MaxStrLen(OGFingerprint));
            OGDescription := CopyStr(StrSubstNo('Warehouse shipment %1 has remained open too long', OGWhseShipmentHeader."No."), 1, MaxStrLen(OGDescription));
            OGDetails := CopyStr(StrSubstNo('Location %1; created %2.', OGWhseShipmentHeader."Location Code", OGWhseShipmentHeader.SystemCreatedAt), 1, MaxStrLen(OGDetails));
            OGRecommendation := CopyStr('Review picks, item availability, and shipment readiness; post or remove obsolete warehouse work.', 1, MaxStrLen(OGRecommendation));

            OGExceptionEngine.OGUpsertException(
                OGRuleSetup,
                OGFingerprint,
                Database::"Warehouse Shipment Header",
                OGWhseShipmentHeader.SystemId,
                OGWhseShipmentHeader."No.",
                OGDescription,
                OGDetails,
                OGRecommendation,
                OGRunId,
                OGRunAt);
        until OGWhseShipmentHeader.Next() = 0;
    end;
}
