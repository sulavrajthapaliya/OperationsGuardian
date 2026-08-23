codeunit 71013 "OG Warehouse Rules" implements "OG Rule Provider"
{
    procedure OGEvaluate(OGRuleSetup: Record "OG Rule Setup"; OGRunId: Guid; OGRunAt: DateTime)
    var
        OGWhseShipmentHeader: Record "Warehouse Shipment Header";
        OGExceptionEngine: Codeunit "OG Exception Engine";
        OGCutoffDateTime: DateTime;
        OGDescription: Text[250];
        OGFingerprint: Text[250];
        OGRecommendation: Text[250];
        OGDetails: Text[2048];
    begin
        if OGRuleSetup."OG Code" <> 'WHSE-SHIPMENT-STUCK' then
            exit;

        OGCutoffDateTime := CreateDateTime(Today() - OGRuleSetup."OG Threshold Days", 000000T);
        OGWhseShipmentHeader.SetFilter(SystemCreatedAt, '<=%1', OGCutoffDateTime);

        if not OGWhseShipmentHeader.FindSet() then
            exit;

        repeat
            OGFingerprint := CopyStr(StrSubstNo(OGWhseShipFingerprintFormatLbl, OGWhseShipmentHeader."No."), 1, MaxStrLen(OGFingerprint));
            OGDescription := CopyStr(StrSubstNo(OGWhseShipDescriptionFormatLbl, OGWhseShipmentHeader."No."), 1, MaxStrLen(OGDescription));
            OGDetails := CopyStr(StrSubstNo(OGWhseShipDetailsFormatLbl, OGWhseShipmentHeader."Location Code", OGWhseShipmentHeader.SystemCreatedAt), 1, MaxStrLen(OGDetails));
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

    var
        OGWhseShipDescriptionFormatLbl: Label 'Warehouse shipment %1 has remained open too long', Comment = '%1 is warehouse shipment number';
        OGWhseShipDetailsFormatLbl: Label 'Location %1; created %2.', Comment = '%1 = location code, %2 = creation timestamp';
        OGWhseShipFingerprintFormatLbl: Label 'WHSESHIP|%1', Comment = '%1 = warehouse shipment number';
}
