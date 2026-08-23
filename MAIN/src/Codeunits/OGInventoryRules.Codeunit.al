codeunit 71012 "OG Inventory Rules" implements "OG Rule Provider"
{
    procedure OGEvaluate(OGRuleSetup: Record "OG Rule Setup"; OGRunId: Guid; OGRunAt: DateTime)
    var
        OGItem: Record Item;
        OGExceptionEngine: Codeunit "OG Exception Engine";
        OGFingerprint: Text[250];
        OGDescription: Text[250];
        OGDetails: Text[2048];
        OGRecommendation: Text[250];
    begin
        if OGRuleSetup."OG Code" <> 'ITEM-BELOW-SAFETY-STOCK' then
            exit;

        OGItem.SetRange(Blocked, false);
        OGItem.SetFilter("Safety Stock Quantity", '>%1', 0);

        if not OGItem.FindSet() then
            exit;

        repeat
            OGItem.CalcFields(Inventory);
            if OGItem.Inventory < OGItem."Safety Stock Quantity" then begin
                OGFingerprint := CopyStr(StrSubstNo('ITEM|%1', OGItem."No."), 1, MaxStrLen(OGFingerprint));
                OGDescription := CopyStr(StrSubstNo('Item %1 is below safety stock', OGItem."No."), 1, MaxStrLen(OGDescription));
                OGDetails := CopyStr(StrSubstNo('Inventory %1; safety stock %2; shortage %3.', OGItem.Inventory, OGItem."Safety Stock Quantity", OGItem."Safety Stock Quantity" - OGItem.Inventory), 1, MaxStrLen(OGDetails));
                OGRecommendation := CopyStr('Review demand and replenishment, then create or expedite supply if required.', 1, MaxStrLen(OGRecommendation));

                OGExceptionEngine.OGUpsertException(
                    OGRuleSetup,
                    OGFingerprint,
                    Database::Item,
                    OGItem.SystemId,
                    OGItem."No.",
                    OGDescription,
                    OGDetails,
                    OGRecommendation,
                    OGRunId,
                    OGRunAt);
            end;
        until OGItem.Next() = 0;
    end;
}
