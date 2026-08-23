codeunit 71010 "OG Sales Rules" implements "OG Rule Provider"
{
    procedure OGEvaluate(OGRuleSetup: Record "OG Rule Setup"; OGRunId: Guid; OGRunAt: DateTime)
    var
        OGSalesHeader: Record "Sales Header";
        OGExceptionEngine: Codeunit "OG Exception Engine";
        OGCutoffDate: Date;
        OGOutstandingQty: Decimal;
        OGDescription: Text[250];
        OGFingerprint: Text[250];
        OGRecommendation: Text[250];
        OGDetails: Text[2048];
    begin
        if OGRuleSetup."OG Code" <> 'SALES-OVERDUE' then
            exit;

        OGCutoffDate := Today() - OGRuleSetup."OG Threshold Days";

        OGSalesHeader.SetRange("Document Type", OGSalesHeader."Document Type"::Order);
        OGSalesHeader.SetRange(Status, OGSalesHeader.Status::Released);
        OGSalesHeader.SetFilter("Shipment Date", '<>%1&<=%2', 0D, OGCutoffDate);

        if not OGSalesHeader.FindSet() then
            exit;

        repeat
            OGOutstandingQty := OGGetOutstandingSalesQty(OGSalesHeader);
            if OGOutstandingQty > 0 then begin
                OGFingerprint := CopyStr(StrSubstNo(OGSalesFingerprintFormatLbl, OGSalesHeader."No."), 1, MaxStrLen(OGFingerprint));
                OGDescription := CopyStr(StrSubstNo(OGSalesDescriptionFormatLbl, OGSalesHeader."No."), 1, MaxStrLen(OGDescription));
                OGDetails := CopyStr(StrSubstNo(OGSalesDetailsFormatLbl, OGSalesHeader."Sell-to Customer No.", OGSalesHeader."Shipment Date", OGOutstandingQty), 1, MaxStrLen(OGDetails));
                OGRecommendation := CopyStr('Review availability, warehouse status, and customer commitment, then update or ship the order.', 1, MaxStrLen(OGRecommendation));

                OGExceptionEngine.OGUpsertException(
                    OGRuleSetup,
                    OGFingerprint,
                    Database::"Sales Header",
                    OGSalesHeader.SystemId,
                    OGSalesHeader."No.",
                    OGDescription,
                    OGDetails,
                    OGRecommendation,
                    OGRunId,
                    OGRunAt);
            end;
        until OGSalesHeader.Next() = 0;
    end;

    local procedure OGGetOutstandingSalesQty(OGSalesHeader: Record "Sales Header"): Decimal
    var
        OGSalesLine: Record "Sales Line";
        OGOutstandingQty: Decimal;
    begin
        OGSalesLine.SetRange("Document Type", OGSalesHeader."Document Type");
        OGSalesLine.SetRange("Document No.", OGSalesHeader."No.");
        OGSalesLine.SetFilter("Outstanding Quantity", '>%1', 0);

        if OGSalesLine.FindSet() then
            repeat
                OGOutstandingQty += OGSalesLine."Outstanding Quantity";
            until OGSalesLine.Next() = 0;

        exit(OGOutstandingQty);
    end;

    var
        OGSalesDescriptionFormatLbl: Label 'Sales order %1 is overdue for shipment', Comment = '%1 = sales order number';
        OGSalesDetailsFormatLbl: Label 'Customer %1; shipment date %2; outstanding quantity %3.', Comment = '%1 = customer number, %2 = shipment date, %3 = outstanding quantity';
        OGSalesFingerprintFormatLbl: Label 'SALES|%1', Comment = '%1 = sales order number';
}
