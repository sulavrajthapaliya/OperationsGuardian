codeunit 71014 "ManufacturingRules_OG_SRT" implements "RuleProvider_OG_SRT"
{
    procedure OGEvaluate(OGRuleSetup: Record "RuleSetup_OG_SRT"; OGRunId: Guid; OGRunAt: DateTime)
    var
        OGItem: Record Item;
        OGProdOrderComponent: Record "Prod. Order Component";
        OGProdOrder: Record "Production Order";
        OGExceptionEngine: Codeunit "ExceptionEngine_OG_SRT";
        OGAvailableInventory: Decimal;
        OGDescription: Text[250];
        OGFingerprint: Text[250];
        OGRecommendation: Text[250];
        OGDetails: Text[2048];
    begin
        if OGRuleSetup."Code" <> 'PROD-COMP-SHORTAGE' then
            exit;

        OGProdOrder.SetRange(Status, OGProdOrder.Status::Released);
        if not OGProdOrder.FindSet() then
            exit;

        repeat
            OGProdOrderComponent.Reset();
            OGProdOrderComponent.SetRange(Status, OGProdOrder.Status);
            OGProdOrderComponent.SetRange("Prod. Order No.", OGProdOrder."No.");
            OGProdOrderComponent.SetFilter("Remaining Quantity", '>%1', 0);

            if OGProdOrderComponent.FindSet() then
                repeat
                    if OGItem.Get(OGProdOrderComponent."Item No.") then begin
                        OGItem.SetRange("Location Filter", OGProdOrderComponent."Location Code");
                        OGItem.CalcFields(Inventory);
                        OGAvailableInventory := OGItem.Inventory;
                        OGItem.SetRange("Location Filter");

                        if OGAvailableInventory < OGProdOrderComponent."Remaining Quantity" then begin
                            OGFingerprint := CopyStr(StrSubstNo(OGProdCompFingerprintFormatLbl, OGProdOrderComponent."Prod. Order No.", OGProdOrderComponent."Prod. Order Line No.", OGProdOrderComponent."Line No."), 1, MaxStrLen(OGFingerprint));
                            OGDescription := CopyStr(StrSubstNo(OGProdCompDescriptionFormatLbl, OGProdOrder."No.", OGProdOrderComponent."Item No."), 1, MaxStrLen(OGDescription));
                            OGDetails := CopyStr(StrSubstNo(OGProdCompDetailsFormatLbl, OGProdOrderComponent."Location Code", OGProdOrderComponent."Remaining Quantity", OGAvailableInventory, OGProdOrderComponent."Remaining Quantity" - OGAvailableInventory), 1, MaxStrLen(OGDetails));
                            OGRecommendation := CopyStr('Review reservations and inbound supply, then replenish or reschedule the production order.', 1, MaxStrLen(OGRecommendation));

                            OGExceptionEngine.OGUpsertException(
                                OGRuleSetup,
                                OGFingerprint,
                                Database::"Prod. Order Component",
                                OGProdOrderComponent.SystemId,
                                OGProdOrder."No.",
                                OGDescription,
                                OGDetails,
                                OGRecommendation,
                                OGRunId,
                                OGRunAt);
                        end;
                    end;
                until OGProdOrderComponent.Next() = 0;
        until OGProdOrder.Next() = 0;
    end;

    var
        OGProdCompDescriptionFormatLbl: Label 'Production order %1 has a shortage of component %2', Comment = '%1 = production order number, %2 = item number';
        OGProdCompDetailsFormatLbl: Label 'Location %1; remaining requirement %2; inventory %3; shortage %4.', Comment = '%1 = location code, %2 = remaining quantity, %3 = available inventory, %4 = shortage quantity';
        OGProdCompFingerprintFormatLbl: Label 'PRODCOMP|%1|%2|%3', Comment = '%1 = production order number, %2 = production order line number, %3 = line number';
}
