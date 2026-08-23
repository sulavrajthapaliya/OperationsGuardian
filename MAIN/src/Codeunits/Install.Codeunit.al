codeunit 71002 "OG Install"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    var
        OGRuleSetupMgt: Codeunit "OG Rule Setup Mgt.";
    begin
        OGRuleSetupMgt.OGEnsureDefaults();
    end;
}
