enum 71003 "RuleProvider_OG_SRT" implements "RuleProvider_OG_SRT"
{
    DefaultImplementation = "RuleProvider_OG_SRT" = "NullRuleProvider_OG_SRT";
    Extensible = true;
    UnknownValueImplementation = "RuleProvider_OG_SRT" = "NullRuleProvider_OG_SRT";

    value(0; "None")
    {
        Caption = 'None';
        Implementation = "RuleProvider_OG_SRT" = "NullRuleProvider_OG_SRT";
    }
    value(1; "Sales")
    {
        Caption = 'Sales';
        Implementation = "RuleProvider_OG_SRT" = "SalesRules_OG_SRT";
    }
    value(2; "Purchasing")
    {
        Caption = 'Purchasing';
        Implementation = "RuleProvider_OG_SRT" = "PurchaseRules_OG_SRT";
    }
    value(3; "Inventory")
    {
        Caption = 'Inventory';
        Implementation = "RuleProvider_OG_SRT" = "InventoryRules_OG_SRT";
    }
    value(4; "Warehouse")
    {
        Caption = 'Warehouse';
        Implementation = "RuleProvider_OG_SRT" = "WarehouseRules_OG_SRT";
    }
    value(5; "Manufacturing")
    {
        Caption = 'Manufacturing';
        Implementation = "RuleProvider_OG_SRT" = "ManufacturingRules_OG_SRT";
    }
    value(6; "System")
    {
        Caption = 'System';
        Implementation = "RuleProvider_OG_SRT" = "SystemRules_OG_SRT";
    }
    value(7; "Approvals")
    {
        Caption = 'Approvals';
        Implementation = "RuleProvider_OG_SRT" = "ApprovalRules_OG_SRT";
    }
    value(8; "Setup")
    {
        Caption = 'Setup';
        Implementation = "RuleProvider_OG_SRT" = "SetupRules_OG_SRT";
    }
}
