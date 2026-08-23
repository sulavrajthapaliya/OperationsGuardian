codeunit 71014 "OG Manufacturing Rules" implements "OG Rule Provider"
{
    procedure OGEvaluate(OGRuleSetup: Record "OG Rule Setup"; OGRunId: Guid; OGRunAt: DateTime)
    var
        OGProdOrder: Record "Production Order";
        OGProdOrderComponent: Record "Prod. Order Component";
        OGItem: Record Item;
        OGExceptionEngine: Codeunit "OG Exception Engine";
        OGAvailableInventory: Decimal;
        OGFingerprint: Text[250];
        OGDescription: Text[250];
        OGDetails: Text[2048];
        OGRecommendation: Text[250];
    begin
        if OGRuleSetup."OG Code" <> 'PROD-COMP-SHORTAGE' then
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
                            OGFingerprint := CopyStr(StrSubstNo('PRODCOMP|%1|%2|%3', OGProdOrderComponent."Prod. Order No.", OGProdOrderComponent."Prod. Order Line No.", OGProdOrderComponent."Line No."), 1, MaxStrLen(OGFingerprint));
                            OGDescription := CopyStr(StrSubstNo('Production order %1 has a shortage of component %2', OGProdOrder."No.", OGProdOrderComponent."Item No."), 1, MaxStrLen(OGDescription));
                            OGDetails := CopyStr(StrSubstNo('Location %1; remaining requirement %2; inventory %3; shortage %4.', OGProdOrderComponent."Location Code", OGProdOrderComponent."Remaining Quantity", OGAvailableInventory, OGProdOrderComponent."Remaining Quantity" - OGAvailableInventory), 1, MaxStrLen(OGDetails));
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
}
