codeunit 71011 "OG Purchase Rules" implements "OG Rule Provider"
{
    procedure OGEvaluate(OGRuleSetup: Record "OG Rule Setup"; OGRunId: Guid; OGRunAt: DateTime)
    var
        OGPurchaseHeader: Record "Purchase Header";
        OGExceptionEngine: Codeunit "OG Exception Engine";
        OGCutoffDate: Date;
        OGQtyToInvoice: Decimal;
        OGFingerprint: Text[250];
        OGDescription: Text[250];
        OGDetails: Text[2048];
        OGRecommendation: Text[250];
    begin
        if OGRuleSetup."OG Code" <> 'PO-RECEIVED-NOT-INVOICED' then
            exit;

        OGCutoffDate := Today() - OGRuleSetup."OG Threshold Days";

        OGPurchaseHeader.SetRange("Document Type", OGPurchaseHeader."Document Type"::Order);
        OGPurchaseHeader.SetFilter("Order Date", '<>%1&<=%2', 0D, OGCutoffDate);

        if not OGPurchaseHeader.FindSet() then
            exit;

        repeat
            OGQtyToInvoice := OGGetReceivedNotInvoicedQty(OGPurchaseHeader);
            if OGQtyToInvoice > 0 then begin
                OGFingerprint := CopyStr(StrSubstNo('PURCHASE|%1', OGPurchaseHeader."No."), 1, MaxStrLen(OGFingerprint));
                OGDescription := CopyStr(StrSubstNo('Purchase order %1 has received quantity not invoiced', OGPurchaseHeader."No."), 1, MaxStrLen(OGDescription));
                OGDetails := CopyStr(StrSubstNo('Vendor %1; order date %2; received-not-invoiced quantity %3.', OGPurchaseHeader."Buy-from Vendor No.", OGPurchaseHeader."Order Date", OGQtyToInvoice), 1, MaxStrLen(OGDetails));
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
        OGQtyToInvoice: Decimal;
        OGLineQty: Decimal;
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
}
