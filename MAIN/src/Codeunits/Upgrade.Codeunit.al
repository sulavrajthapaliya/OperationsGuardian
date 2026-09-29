codeunit 71099 "Upgrade_OG_SRT"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        OGRuleSetupMgt: Codeunit "RuleSetupMgt_OG_SRT";
    begin
        OGRuleSetupMgt.OGEnsureDefaults();
    end;
}
