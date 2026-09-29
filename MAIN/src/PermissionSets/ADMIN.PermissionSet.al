permissionset 71001 "ADMIN_OG_SRT"
{
    Assignable = true;
    Caption = 'Operations Guardian Administrator';
    IncludedPermissionSets = "USER_OG_SRT";

    Permissions =
        tabledata "Cue_OG_SRT" = RIMD,
        tabledata "Exception_OG_SRT" = RIMD,
        tabledata "RuleSetup_OG_SRT" = RIMD,
        codeunit "RuleSetupMgt_OG_SRT" = X;
}
