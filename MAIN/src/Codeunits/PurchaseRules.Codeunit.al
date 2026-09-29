codeunit 71011 "PurchaseRules_OG_SRT" implements "RuleProvider_OG_SRT"
{
    procedure OGEvaluate(OGRuleSetup: Record "RuleSetup_OG_SRT"; OGRunId: Guid; OGRunAt: DateTime)
    var
        OGPurchaseHeader: Record "Purchase Header";
        OGExceptionEngine: Codeunit "ExceptionEngine_OG_SRT";
        OGCutoffDate: Date;
        OGQtyToInvoice: Decimal;
        OGDescription: Text[250];
        OGFingerprint: Text[250];
        OGRecommendation: Text[250];
        OGDetails: Text[2048];
    begin
        if OGRuleSetup."Code" <> 'PO-RECEIVED-NOT-INVOICED' then
            exit;

        OGCutoffDate := Today() - OGRuleSetup."Threshold Days";

        OGPurchaseHeader.SetRange("Document Type", OGPurchaseHeader."Document Type"::Order);
        OGPurchaseHeader.SetFilter("Order Date", '<>%1&<=%2', 0D, OGCutoffDate);

        if not OGPurchaseHeader.FindSet() then
            exit;

        repeat
            OGQtyToInvoice := OGGetReceivedNotInvoicedQty(OGPurchaseHeader);
            if OGQtyToInvoice > 0 then begin
                OGFingerprint := CopyStr(StrSubstNo(OGPurchaseFingerprintFormatLbl, OGPurchaseHeader."No."), 1, MaxStrLen(OGFingerprint));
                OGDescription := CopyStr(StrSubstNo(OGPurchaseDescriptionFormatLbl, OGPurchaseHeader."No."), 1, MaxStrLen(OGDescription));
                OGDetails := CopyStr(StrSubstNo(OGPurchaseDetailsFormatLbl, OGPurchaseHeader."Buy-from Vendor No.", OGPurchaseHeader."Order Date", OGQtyToInvoice), 1, MaxStrLen(OGDetails));
                OGRecommendation := CopyStr('Review the vendor invoice status and post the invoice or correct the receipt.', 1, MaxStrLen(OGRecommendation));

                OGExceptionEngine.OGUpsertException(
                    OGRuleSetup,
                    OGFingerprint,
                    Database::"Purchase Header",
                    OGPurchaseHeader.SystemId,
                    OGPurchaseHeader."No.",
                    OGDescription,
                    OGDetails,
                    OGRecommendation,
                    OGRunId,
                    OGRunAt);
            end;
        until OGPurchaseHeader.Next() = 0;
    end;

    local procedure OGGetReceivedNotInvoicedQty(OGPurchaseHeader: Record "Purchase Header"): Decimal
    var
        OGPurchaseLine: Record "Purchase Line";
        OGLineQty: Decimal;
        OGQtyToInvoice: Decimal;
    begin
        OGPurchaseLine.SetRange("Document Type", OGPurchaseHeader."Document Type");
        OGPurchaseLine.SetRange("Document No.", OGPurchaseHeader."No.");

        if OGPurchaseLine.FindSet() then
            repeat
                OGLineQty := OGPurchaseLine."Quantity Received" - OGPurchaseLine."Quantity Invoiced";
                if OGLineQty > 0 then
                    OGQtyToInvoice += OGLineQty;
            until OGPurchaseLine.Next() = 0;

        exit(OGQtyToInvoice);
    end;

    var
        OGPurchaseDescriptionFormatLbl: Label 'Purchase order %1 has received quantity not invoiced', Comment = '%1 = purchase order number';
        OGPurchaseDetailsFormatLbl: Label 'Vendor %1; order date %2; received-not-invoiced quantity %3.', Comment = '%1 = vendor number, %2 = order date, %3 = received-not-invoiced quantity';
        OGPurchaseFingerprintFormatLbl: Label 'PURCHASE|%1', Comment = '%1 = purchase order number';
}
