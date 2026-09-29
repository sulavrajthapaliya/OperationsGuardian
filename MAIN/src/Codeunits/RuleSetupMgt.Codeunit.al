codeunit 71001 "RuleSetupMgt_OG_SRT"
{
    procedure OGEnsureDefaults()
    begin
        OGInsertRule('SALES-OVERDUE', 'Released sales order is overdue for shipment', "ExceptionArea_OG_SRT"::"Sales", "ExceptionSeverity_OG_SRT"::"Warning", "RuleProvider_OG_SRT"::"Sales", 7);
        OGInsertRule('PO-RECEIVED-NOT-INVOICED', 'Purchase order has received quantity not invoiced', "ExceptionArea_OG_SRT"::"Purchasing", "ExceptionSeverity_OG_SRT"::"Warning", "RuleProvider_OG_SRT"::"Purchasing", 3);
        OGInsertRule('ITEM-BELOW-SAFETY-STOCK', 'Item inventory is below safety stock', "ExceptionArea_OG_SRT"::"Inventory", "ExceptionSeverity_OG_SRT"::"Critical", "RuleProvider_OG_SRT"::"Inventory", 0);
        OGInsertRule('WHSE-SHIPMENT-STUCK', 'Warehouse shipment has remained open too long', "ExceptionArea_OG_SRT"::"Warehouse", "ExceptionSeverity_OG_SRT"::"Warning", "RuleProvider_OG_SRT"::"Warehouse", 2);
        OGInsertRule('PROD-COMP-SHORTAGE', 'Released production order has a component shortage', "ExceptionArea_OG_SRT"::"Manufacturing", "ExceptionSeverity_OG_SRT"::"Critical", "RuleProvider_OG_SRT"::"Manufacturing", 0);
        OGInsertRule('JOB-QUEUE-FAILED', 'Job queue entry is in Error status', "ExceptionArea_OG_SRT"::"System", "ExceptionSeverity_OG_SRT"::"Critical", "RuleProvider_OG_SRT"::"System", 0);
        OGInsertRule('APPROVAL-AGING', 'Open approval request has waited too long', "ExceptionArea_OG_SRT"::"Approvals", "ExceptionSeverity_OG_SRT"::"Warning", "RuleProvider_OG_SRT"::"Approvals", 2);
        OGInsertRule('NO-SERIES-EXHAUSTION', 'Current number series line is at or beyond its warning number, or is exhausted', "ExceptionArea_OG_SRT"::"System", "ExceptionSeverity_OG_SRT"::"Warning", "RuleProvider_OG_SRT"::"System", 0);
        OGInsertRule('COMPANY-INFO-INCOMPLETE', 'Company information has missing core fields', "ExceptionArea_OG_SRT"::"Setup", "ExceptionSeverity_OG_SRT"::"Warning", "RuleProvider_OG_SRT"::"Setup", 0);
        OGInsertRule('GL-SETUP-INCOMPLETE', 'General ledger setup has missing core fields', "ExceptionArea_OG_SRT"::"Setup", "ExceptionSeverity_OG_SRT"::"Critical", "RuleProvider_OG_SRT"::"Setup", 0);
        OGInsertRule('SALES-SETUP-INCOMPLETE', 'Sales setup has missing core number series', "ExceptionArea_OG_SRT"::"Setup", "ExceptionSeverity_OG_SRT"::"Critical", "RuleProvider_OG_SRT"::"Setup", 0);
        OGInsertRule('PURCHASE-SETUP-INCOMPLETE', 'Purchase setup has missing core number series', "ExceptionArea_OG_SRT"::"Setup", "ExceptionSeverity_OG_SRT"::"Critical", "RuleProvider_OG_SRT"::"Setup", 0);
        OGInsertRule('INVENTORY-SETUP-INCOMPLETE', 'Inventory setup has missing core number series', "ExceptionArea_OG_SRT"::"Setup", "ExceptionSeverity_OG_SRT"::"Warning", "RuleProvider_OG_SRT"::"Setup", 0);
        OGInsertRule('GEN-POSTING-SETUP-INCOMPLETE', 'General posting setup has missing core accounts', "ExceptionArea_OG_SRT"::"Setup", "ExceptionSeverity_OG_SRT"::"Critical", "RuleProvider_OG_SRT"::"Setup", 0);
        OGInsertRule('INVT-POSTING-SETUP-INCOMPLETE', 'Inventory posting setup has missing core accounts', "ExceptionArea_OG_SRT"::"Setup", "ExceptionSeverity_OG_SRT"::"Critical", "RuleProvider_OG_SRT"::"Setup", 0);

        OGEnsureCueRecord();
    end;

    procedure OGEnsureCueRecord()
    var
        OGCue: Record "Cue_OG_SRT";
    begin
        if OGCue.Get(1) then
            exit;

        OGCue.Init();
        OGCue."Primary Key" := 1;
        OGCue.Insert();
    end;

    local procedure OGInsertRule(OGCode: Code[50]; OGDescription: Text[100]; OGArea: Enum "ExceptionArea_OG_SRT"; OGSeverity: Enum "ExceptionSeverity_OG_SRT"; OGProvider: Enum "RuleProvider_OG_SRT"; OGThresholdDays: Integer)
    var
        OGRuleSetup: Record "RuleSetup_OG_SRT";
    begin
        if OGRuleSetup.Get(OGCode) then
            exit;

        OGRuleSetup.Init();
        OGRuleSetup."Code" := OGCode;
        OGRuleSetup."Description" := OGDescription;
        OGRuleSetup."Area" := OGArea;
        OGRuleSetup."Severity" := OGSeverity;
        OGRuleSetup."Enabled" := true;
        OGRuleSetup."Provider" := OGProvider;
        OGRuleSetup."Threshold Days" := OGThresholdDays;
        OGRuleSetup.Insert(true);
    end;
}
