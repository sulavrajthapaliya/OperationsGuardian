codeunit 71001 "OG Rule Setup Mgt."
{
    procedure OGEnsureDefaults()
    begin
        OGInsertRule('SALES-OVERDUE', 'Released sales order is overdue for shipment', "OG Exception Area"::"OG Sales", "OG Exception Severity"::"OG Warning", "OG Rule Provider"::"OG Sales", 7);
        OGInsertRule('PO-RECEIVED-NOT-INVOICED', 'Purchase order has received quantity not invoiced', "OG Exception Area"::"OG Purchasing", "OG Exception Severity"::"OG Warning", "OG Rule Provider"::"OG Purchasing", 3);
        OGInsertRule('ITEM-BELOW-SAFETY-STOCK', 'Item inventory is below safety stock', "OG Exception Area"::"OG Inventory", "OG Exception Severity"::"OG Critical", "OG Rule Provider"::"OG Inventory", 0);
        OGInsertRule('WHSE-SHIPMENT-STUCK', 'Warehouse shipment has remained open too long', "OG Exception Area"::"OG Warehouse", "OG Exception Severity"::"OG Warning", "OG Rule Provider"::"OG Warehouse", 2);
        OGInsertRule('PROD-COMP-SHORTAGE', 'Released production order has a component shortage', "OG Exception Area"::"OG Manufacturing", "OG Exception Severity"::"OG Critical", "OG Rule Provider"::"OG Manufacturing", 0);
        OGInsertRule('JOB-QUEUE-FAILED', 'Job queue entry is in Error status', "OG Exception Area"::"OG System", "OG Exception Severity"::"OG Critical", "OG Rule Provider"::"OG System", 0);
        OGInsertRule('APPROVAL-AGING', 'Open approval request has waited too long', "OG Exception Area"::"OG Approvals", "OG Exception Severity"::"OG Warning", "OG Rule Provider"::"OG Approvals", 2);
        OGInsertRule('NO-SERIES-EXHAUSTION', 'Current number series line is at or beyond its warning number, or is exhausted', "OG Exception Area"::"OG System", "OG Exception Severity"::"OG Warning", "OG Rule Provider"::"OG System", 0);
        OGInsertRule('COMPANY-INFO-INCOMPLETE', 'Company information has missing core fields', "OG Exception Area"::"OG Setup", "OG Exception Severity"::"OG Warning", "OG Rule Provider"::"OG Setup", 0);
        OGInsertRule('GL-SETUP-INCOMPLETE', 'General ledger setup has missing core fields', "OG Exception Area"::"OG Setup", "OG Exception Severity"::"OG Critical", "OG Rule Provider"::"OG Setup", 0);
        OGInsertRule('SALES-SETUP-INCOMPLETE', 'Sales setup has missing core number series', "OG Exception Area"::"OG Setup", "OG Exception Severity"::"OG Critical", "OG Rule Provider"::"OG Setup", 0);
        OGInsertRule('PURCHASE-SETUP-INCOMPLETE', 'Purchase setup has missing core number series', "OG Exception Area"::"OG Setup", "OG Exception Severity"::"OG Critical", "OG Rule Provider"::"OG Setup", 0);
        OGInsertRule('INVENTORY-SETUP-INCOMPLETE', 'Inventory setup has missing core number series', "OG Exception Area"::"OG Setup", "OG Exception Severity"::"OG Warning", "OG Rule Provider"::"OG Setup", 0);
        OGInsertRule('GEN-POSTING-SETUP-INCOMPLETE', 'General posting setup has missing core accounts', "OG Exception Area"::"OG Setup", "OG Exception Severity"::"OG Critical", "OG Rule Provider"::"OG Setup", 0);
        OGInsertRule('INVT-POSTING-SETUP-INCOMPLETE', 'Inventory posting setup has missing core accounts', "OG Exception Area"::"OG Setup", "OG Exception Severity"::"OG Critical", "OG Rule Provider"::"OG Setup", 0);

        OGEnsureCueRecord();
    end;

    procedure OGEnsureCueRecord()
    var
        OGCue: Record "OG Cue";
    begin
        if OGCue.Get(1) then
            exit;

        OGCue.Init();
        OGCue."OG Primary Key" := 1;
        OGCue.Insert();
    end;

    local procedure OGInsertRule(OGCode: Code[50]; OGDescription: Text[100]; OGArea: Enum "OG Exception Area"; OGSeverity: Enum "OG Exception Severity"; OGProvider: Enum "OG Rule Provider"; OGThresholdDays: Integer)
    var
        OGRuleSetup: Record "OG Rule Setup";
    begin
        if OGRuleSetup.Get(OGCode) then
            exit;

        OGRuleSetup.Init();
        OGRuleSetup."OG Code" := OGCode;
        OGRuleSetup."OG Description" := OGDescription;
        OGRuleSetup."OG Area" := OGArea;
        OGRuleSetup."OG Severity" := OGSeverity;
        OGRuleSetup."OG Enabled" := true;
        OGRuleSetup."OG Provider" := OGProvider;
        OGRuleSetup."OG Threshold Days" := OGThresholdDays;
        OGRuleSetup.Insert(true);
    end;
}
