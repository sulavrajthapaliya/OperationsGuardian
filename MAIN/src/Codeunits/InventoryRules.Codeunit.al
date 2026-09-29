codeunit 71012 "InventoryRules_OG_SRT" implements "RuleProvider_OG_SRT"
{
    procedure OGEvaluate(OGRuleSetup: Record "RuleSetup_OG_SRT"; OGRunId: Guid; OGRunAt: DateTime)
    var
        OGItem: Record Item;
        OGExceptionEngine: Codeunit "ExceptionEngine_OG_SRT";
        OGDescription: Text[250];
        OGFingerprint: Text[250];
        OGRecommendation: Text[250];
        OGDetails: Text[2048];
    begin
        if OGRuleSetup."Code" <> 'ITEM-BELOW-SAFETY-STOCK' then
            exit;

        OGItem.SetRange(Blocked, false);
        OGItem.SetFilter("Safety Stock Quantity", '>%1', 0);

        if not OGItem.FindSet() then
            exit;

        repeat
            OGItem.CalcFields(Inventory);
            if OGItem.Inventory < OGItem."Safety Stock Quantity" then begin
                OGFingerprint := CopyStr(StrSubstNo(OGItemFingerprintFormatLbl, OGItem."No."), 1, MaxStrLen(OGFingerprint));
                OGDescription := CopyStr(StrSubstNo(OGItemDescriptionFormatLbl, OGItem."No."), 1, MaxStrLen(OGDescription));
                OGDetails := CopyStr(StrSubstNo(OGItemDetailsFormatLbl, OGItem.Inventory, OGItem."Safety Stock Quantity", OGItem."Safety Stock Quantity" - OGItem.Inventory), 1, MaxStrLen(OGDetails));
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

    var
        OGItemDescriptionFormatLbl: Label 'Item %1 is below safety stock', Comment = '%1 = item number';
        OGItemDetailsFormatLbl: Label 'Inventory %1; safety stock %2; shortage %3.', Comment = '%1 = inventory quantity, %2 = safety stock quantity, %3 = shortage quantity';
        OGItemFingerprintFormatLbl: Label 'ITEM|%1', Comment = '%1 = item number';
}
