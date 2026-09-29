codeunit 71002 "Install_OG_SRT"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    var
        OGRuleSetupMgt: Codeunit "RuleSetupMgt_OG_SRT";
    begin
        OGRuleSetupMgt.OGEnsureDefaults();
    end;
}
