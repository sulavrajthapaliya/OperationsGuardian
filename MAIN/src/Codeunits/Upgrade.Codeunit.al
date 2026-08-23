codeunit 71099 "OG Upgrade"
{
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        OGRuleSetupMgt: Codeunit "OG Rule Setup Mgt.";
    begin
        OGRuleSetupMgt.OGEnsureDefaults();
    end;
}
