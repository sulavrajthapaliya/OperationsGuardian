codeunit 71017 "OG Setup Rules" implements "OG Rule Provider"
{
    procedure OGEvaluate(OGRuleSetup: Record "OG Rule Setup"; OGRunId: Guid; OGRunAt: DateTime)
    begin
        case OGRuleSetup."OG Code" of
            'COMPANY-INFO-INCOMPLETE':
                OGEvaluateCompanyInformation(OGRuleSetup, OGRunId, OGRunAt);
            'GL-SETUP-INCOMPLETE':
                OGEvaluateGeneralLedgerSetup(OGRuleSetup, OGRunId, OGRunAt);
            'SALES-SETUP-INCOMPLETE':
                OGEvaluateSalesSetup(OGRuleSetup, OGRunId, OGRunAt);
            'PURCHASE-SETUP-INCOMPLETE':
                OGEvaluatePurchaseSetup(OGRuleSetup, OGRunId, OGRunAt);
            'INVENTORY-SETUP-INCOMPLETE':
                OGEvaluateInventorySetup(OGRuleSetup, OGRunId, OGRunAt);
            'GEN-POSTING-SETUP-INCOMPLETE':
                OGEvaluateGeneralPostingSetup(OGRuleSetup, OGRunId, OGRunAt);
            'INVT-POSTING-SETUP-INCOMPLETE':
                OGEvaluateInventoryPostingSetup(OGRuleSetup, OGRunId, OGRunAt);
        end;
    end;

    local procedure OGEvaluateCompanyInformation(OGRuleSetup: Record "OG Rule Setup"; OGRunId: Guid; OGRunAt: DateTime)
    var
        OGCompanyInformation: Record "Company Information";
        OGMissingFields: Text;
    begin
        if not OGCompanyInformation.Get() then begin
            OGCreateMissingRecordException(OGRuleSetup, 'COMPANY', Database::"Company Information", CompanyInformationLbl, OGRunId, OGRunAt);
            exit;
        end;

        OGAddMissingField(OGMissingFields, OGCompanyInformation.Name = '', OGCompanyInformation.FieldCaption(Name));
        OGAddMissingField(OGMissingFields, OGCompanyInformation.Address = '', OGCompanyInformation.FieldCaption(Address));
        OGAddMissingField(OGMissingFields, OGCompanyInformation.City = '', OGCompanyInformation.FieldCaption(City));
        OGAddMissingField(OGMissingFields, OGCompanyInformation."Post Code" = '', OGCompanyInformation.FieldCaption("Post Code"));
        OGAddMissingField(OGMissingFields, OGCompanyInformation."Country/Region Code" = '', OGCompanyInformation.FieldCaption("Country/Region Code"));

        OGCreateIncompleteSetupException(OGRuleSetup, 'COMPANY', Database::"Company Information", OGCompanyInformation.SystemId, CompanyInformationLbl, OGMissingFields, OGRunId, OGRunAt);
    end;

    local procedure OGEvaluateGeneralLedgerSetup(OGRuleSetup: Record "OG Rule Setup"; OGRunId: Guid; OGRunAt: DateTime)
    var
        OGGeneralLedgerSetup: Record "General Ledger Setup";
        OGMissingFields: Text;
    begin
        if not OGGeneralLedgerSetup.Get() then begin
            OGCreateMissingRecordException(OGRuleSetup, 'GENERAL-LEDGER', Database::"General Ledger Setup", GeneralLedgerSetupLbl, OGRunId, OGRunAt);
            exit;
        end;

        OGAddMissingField(OGMissingFields, OGGeneralLedgerSetup."LCY Code" = '', OGGeneralLedgerSetup.FieldCaption("LCY Code"));

        OGCreateIncompleteSetupException(OGRuleSetup, 'GENERAL-LEDGER', Database::"General Ledger Setup", OGGeneralLedgerSetup.SystemId, GeneralLedgerSetupLbl, OGMissingFields, OGRunId, OGRunAt);
    end;

    local procedure OGEvaluateSalesSetup(OGRuleSetup: Record "OG Rule Setup"; OGRunId: Guid; OGRunAt: DateTime)
    var
        OGSalesSetup: Record "Sales & Receivables Setup";
        OGMissingFields: Text;
    begin
        if not OGSalesSetup.Get() then begin
            OGCreateMissingRecordException(OGRuleSetup, 'SALES', Database::"Sales & Receivables Setup", SalesSetupLbl, OGRunId, OGRunAt);
            exit;
        end;

        OGAddMissingField(OGMissingFields, OGSalesSetup."Customer Nos." = '', OGSalesSetup.FieldCaption("Customer Nos."));
        OGAddMissingField(OGMissingFields, OGSalesSetup."Order Nos." = '', OGSalesSetup.FieldCaption("Order Nos."));
        OGAddMissingField(OGMissingFields, OGSalesSetup."Invoice Nos." = '', OGSalesSetup.FieldCaption("Invoice Nos."));
        OGAddMissingField(OGMissingFields, OGSalesSetup."Posted Invoice Nos." = '', OGSalesSetup.FieldCaption("Posted Invoice Nos."));
        OGAddMissingField(OGMissingFields, OGSalesSetup."Credit Memo Nos." = '', OGSalesSetup.FieldCaption("Credit Memo Nos."));
        OGAddMissingField(OGMissingFields, OGSalesSetup."Posted Credit Memo Nos." = '', OGSalesSetup.FieldCaption("Posted Credit Memo Nos."));
        OGAddMissingField(OGMissingFields, OGSalesSetup."Posted Shipment Nos." = '', OGSalesSetup.FieldCaption("Posted Shipment Nos."));

        OGCreateIncompleteSetupException(OGRuleSetup, 'SALES', Database::"Sales & Receivables Setup", OGSalesSetup.SystemId, SalesSetupLbl, OGMissingFields, OGRunId, OGRunAt);
    end;

    local procedure OGEvaluatePurchaseSetup(OGRuleSetup: Record "OG Rule Setup"; OGRunId: Guid; OGRunAt: DateTime)
    var
        OGPurchaseSetup: Record "Purchases & Payables Setup";
        OGMissingFields: Text;
    begin
        if not OGPurchaseSetup.Get() then begin
            OGCreateMissingRecordException(OGRuleSetup, 'PURCHASE', Database::"Purchases & Payables Setup", PurchaseSetupLbl, OGRunId, OGRunAt);
            exit;
        end;

        OGAddMissingField(OGMissingFields, OGPurchaseSetup."Vendor Nos." = '', OGPurchaseSetup.FieldCaption("Vendor Nos."));
        OGAddMissingField(OGMissingFields, OGPurchaseSetup."Order Nos." = '', OGPurchaseSetup.FieldCaption("Order Nos."));
        OGAddMissingField(OGMissingFields, OGPurchaseSetup."Invoice Nos." = '', OGPurchaseSetup.FieldCaption("Invoice Nos."));
        OGAddMissingField(OGMissingFields, OGPurchaseSetup."Posted Invoice Nos." = '', OGPurchaseSetup.FieldCaption("Posted Invoice Nos."));
        OGAddMissingField(OGMissingFields, OGPurchaseSetup."Credit Memo Nos." = '', OGPurchaseSetup.FieldCaption("Credit Memo Nos."));
        OGAddMissingField(OGMissingFields, OGPurchaseSetup."Posted Credit Memo Nos." = '', OGPurchaseSetup.FieldCaption("Posted Credit Memo Nos."));
        OGAddMissingField(OGMissingFields, OGPurchaseSetup."Posted Receipt Nos." = '', OGPurchaseSetup.FieldCaption("Posted Receipt Nos."));

        OGCreateIncompleteSetupException(OGRuleSetup, 'PURCHASE', Database::"Purchases & Payables Setup", OGPurchaseSetup.SystemId, PurchaseSetupLbl, OGMissingFields, OGRunId, OGRunAt);
    end;

    local procedure OGEvaluateInventorySetup(OGRuleSetup: Record "OG Rule Setup"; OGRunId: Guid; OGRunAt: DateTime)
    var
        OGInventorySetup: Record "Inventory Setup";
        OGMissingFields: Text;
    begin
        if not OGInventorySetup.Get() then begin
            OGCreateMissingRecordException(OGRuleSetup, 'INVENTORY', Database::"Inventory Setup", InventorySetupLbl, OGRunId, OGRunAt);
            exit;
        end;

        OGAddMissingField(OGMissingFields, OGInventorySetup."Item Nos." = '', OGInventorySetup.FieldCaption("Item Nos."));
        OGAddMissingField(OGMissingFields, OGInventorySetup."Transfer Order Nos." = '', OGInventorySetup.FieldCaption("Transfer Order Nos."));
        OGAddMissingField(OGMissingFields, OGInventorySetup."Posted Transfer Shpt. Nos." = '', OGInventorySetup.FieldCaption("Posted Transfer Shpt. Nos."));
        OGAddMissingField(OGMissingFields, OGInventorySetup."Posted Transfer Rcpt. Nos." = '', OGInventorySetup.FieldCaption("Posted Transfer Rcpt. Nos."));

        OGCreateIncompleteSetupException(OGRuleSetup, 'INVENTORY', Database::"Inventory Setup", OGInventorySetup.SystemId, InventorySetupLbl, OGMissingFields, OGRunId, OGRunAt);
    end;

    local procedure OGEvaluateGeneralPostingSetup(OGRuleSetup: Record "OG Rule Setup"; OGRunId: Guid; OGRunAt: DateTime)
    var
        OGGeneralPostingSetup: Record "General Posting Setup";
        OGMissingFields: Text;
        OGSetupKey: Text;
        OGSetupName: Text;
    begin
        if not OGGeneralPostingSetup.FindSet() then begin
            OGCreateMissingRecordException(OGRuleSetup, 'GEN-POSTING', Database::"General Posting Setup", GeneralPostingSetupLbl, OGRunId, OGRunAt);
            exit;
        end;

        repeat
            Clear(OGMissingFields);
            OGAddMissingField(OGMissingFields, OGGeneralPostingSetup."Sales Account" = '', OGGeneralPostingSetup.FieldCaption("Sales Account"));
            OGAddMissingField(OGMissingFields, OGGeneralPostingSetup."Sales Credit Memo Account" = '', OGGeneralPostingSetup.FieldCaption("Sales Credit Memo Account"));
            OGAddMissingField(OGMissingFields, OGGeneralPostingSetup."Purch. Account" = '', OGGeneralPostingSetup.FieldCaption("Purch. Account"));
            OGAddMissingField(OGMissingFields, OGGeneralPostingSetup."Purch. Credit Memo Account" = '', OGGeneralPostingSetup.FieldCaption("Purch. Credit Memo Account"));
            OGAddMissingField(OGMissingFields, OGGeneralPostingSetup."COGS Account" = '', OGGeneralPostingSetup.FieldCaption("COGS Account"));
            OGAddMissingField(OGMissingFields, OGGeneralPostingSetup."Inventory Adjmt. Account" = '', OGGeneralPostingSetup.FieldCaption("Inventory Adjmt. Account"));
            OGAddMissingField(OGMissingFields, OGGeneralPostingSetup."Direct Cost Applied Account" = '', OGGeneralPostingSetup.FieldCaption("Direct Cost Applied Account"));

            OGSetupKey := StrSubstNo(GeneralPostingSetupKeyFormatLbl, OGGeneralPostingSetup."Gen. Bus. Posting Group", OGGeneralPostingSetup."Gen. Prod. Posting Group");
            OGSetupName := StrSubstNo(GeneralPostingSetupNameFormatLbl, OGGeneralPostingSetup."Gen. Bus. Posting Group", OGGeneralPostingSetup."Gen. Prod. Posting Group");
            OGCreateIncompleteSetupException(OGRuleSetup, OGSetupKey, Database::"General Posting Setup", OGGeneralPostingSetup.SystemId, OGSetupName, OGMissingFields, OGRunId, OGRunAt);
        until OGGeneralPostingSetup.Next() = 0;
    end;

    local procedure OGEvaluateInventoryPostingSetup(OGRuleSetup: Record "OG Rule Setup"; OGRunId: Guid; OGRunAt: DateTime)
    var
        OGInventoryPostingSetup: Record "Inventory Posting Setup";
        OGInventorySetup: Record "Inventory Setup";
        OGExpectedCostPosting: Boolean;
        OGMissingFields: Text;
        OGSetupKey: Text;
        OGSetupName: Text;
    begin
        if OGInventorySetup.Get() then
            OGExpectedCostPosting := OGInventorySetup."Expected Cost Posting to G/L";

        if not OGInventoryPostingSetup.FindSet() then begin
            OGCreateMissingRecordException(OGRuleSetup, 'INVT-POSTING', Database::"Inventory Posting Setup", InventoryPostingSetupLbl, OGRunId, OGRunAt);
            exit;
        end;

        repeat
            Clear(OGMissingFields);
            OGAddMissingField(OGMissingFields, OGInventoryPostingSetup."Inventory Account" = '', OGInventoryPostingSetup.FieldCaption("Inventory Account"));
            OGAddMissingField(OGMissingFields, OGExpectedCostPosting and (OGInventoryPostingSetup."Inventory Account (Interim)" = ''), OGInventoryPostingSetup.FieldCaption("Inventory Account (Interim)"));

            OGSetupKey := StrSubstNo(InventoryPostingSetupKeyFormatLbl, OGInventoryPostingSetup."Location Code", OGInventoryPostingSetup."Invt. Posting Group Code");
            OGSetupName := StrSubstNo(InventoryPostingSetupNameFormatLbl, OGInventoryPostingSetup."Location Code", OGInventoryPostingSetup."Invt. Posting Group Code");
            OGCreateIncompleteSetupException(OGRuleSetup, OGSetupKey, Database::"Inventory Posting Setup", OGInventoryPostingSetup.SystemId, OGSetupName, OGMissingFields, OGRunId, OGRunAt);
        until OGInventoryPostingSetup.Next() = 0;
    end;

    local procedure OGAddMissingField(var OGMissingFields: Text; OGIsMissing: Boolean; OGFieldCaption: Text)
    begin
        if not OGIsMissing then
            exit;

        if OGMissingFields <> '' then
            OGMissingFields += ', ';
        OGMissingFields += OGFieldCaption;
    end;

    local procedure OGCreateMissingRecordException(OGRuleSetup: Record "OG Rule Setup"; OGSetupKey: Text; OGSourceTableNo: Integer; OGSetupName: Text; OGRunId: Guid; OGRunAt: DateTime)
    var
        OGEmptySystemId: Guid;
    begin
        Clear(OGEmptySystemId);
        OGCreateException(OGRuleSetup, OGSetupKey, OGSourceTableNo, OGEmptySystemId, OGSetupName, SetupRecordMissingLbl, OGRunId, OGRunAt);
    end;

    local procedure OGCreateIncompleteSetupException(OGRuleSetup: Record "OG Rule Setup"; OGSetupKey: Text; OGSourceTableNo: Integer; OGSourceSystemId: Guid; OGSetupName: Text; OGMissingFields: Text; OGRunId: Guid; OGRunAt: DateTime)
    begin
        if OGMissingFields = '' then
            exit;

        OGCreateException(OGRuleSetup, OGSetupKey, OGSourceTableNo, OGSourceSystemId, OGSetupName, OGMissingFields, OGRunId, OGRunAt);
    end;

    local procedure OGCreateException(OGRuleSetup: Record "OG Rule Setup"; OGSetupKey: Text; OGSourceTableNo: Integer; OGSourceSystemId: Guid; OGSetupName: Text; OGMissingFields: Text; OGRunId: Guid; OGRunAt: DateTime)
    var
        OGExceptionEngine: Codeunit "OG Exception Engine";
        OGDescription: Text[250];
        OGDetails: Text[2048];
        OGFingerprint: Text[250];
        OGRecommendation: Text[250];
        OGSourceNo: Code[50];
    begin
        OGFingerprint := CopyStr(StrSubstNo(SetupFingerprintFormatLbl, OGSetupKey), 1, MaxStrLen(OGFingerprint));
        OGDescription := CopyStr(StrSubstNo(SetupDescriptionFormatLbl, OGSetupName), 1, MaxStrLen(OGDescription));
        OGDetails := CopyStr(StrSubstNo(SetupDetailsFormatLbl, OGSetupName, OGMissingFields), 1, MaxStrLen(OGDetails));
        OGRecommendation := CopyStr(StrSubstNo(SetupRecommendationFormatLbl, OGSetupName), 1, MaxStrLen(OGRecommendation));
        OGSourceNo := CopyStr(OGSetupName, 1, MaxStrLen(OGSourceNo));

        OGExceptionEngine.OGUpsertException(
            OGRuleSetup,
            OGFingerprint,
            OGSourceTableNo,
            OGSourceSystemId,
            OGSourceNo,
            OGDescription,
            OGDetails,
            OGRecommendation,
            OGRunId,
            OGRunAt);
    end;

    var
        CompanyInformationLbl: Label 'Company Information';
        GeneralLedgerSetupLbl: Label 'General Ledger Setup';
        GeneralPostingSetupKeyFormatLbl: Label 'GEN-POSTING|%1|%2', Locked = true, Comment = '%1 = general business posting group, %2 = general product posting group';
        GeneralPostingSetupLbl: Label 'General Posting Setup';
        GeneralPostingSetupNameFormatLbl: Label 'General Posting Setup %1 / %2', Comment = '%1 = general business posting group, %2 = general product posting group';
        InventorySetupLbl: Label 'Inventory Setup';
        InventoryPostingSetupKeyFormatLbl: Label 'INVT-POSTING|%1|%2', Locked = true, Comment = '%1 = location code, %2 = inventory posting group';
        InventoryPostingSetupLbl: Label 'Inventory Posting Setup';
        InventoryPostingSetupNameFormatLbl: Label 'Inventory Posting Setup %1 / %2', Comment = '%1 = location code, %2 = inventory posting group';
        PurchaseSetupLbl: Label 'Purchases & Payables Setup';
        SalesSetupLbl: Label 'Sales & Receivables Setup';
        SetupDescriptionFormatLbl: Label '%1 is incomplete', Comment = '%1 = setup page name';
        SetupDetailsFormatLbl: Label '%1 is missing: %2.', Comment = '%1 = setup page name, %2 = comma-separated field captions';
        SetupFingerprintFormatLbl: Label 'SETUP|%1', Locked = true, Comment = '%1 = stable setup key';
        SetupRecommendationFormatLbl: Label 'Open %1 and complete the missing fields before processing transactions.', Comment = '%1 = setup page name';
        SetupRecordMissingLbl: Label 'the setup record';
}
