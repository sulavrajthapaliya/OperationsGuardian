permissionset 71001 "OG ADMIN"
{
    Assignable = true;
    Caption = 'Operations Guardian Administrator';
    IncludedPermissionSets = "OG USER";

    Permissions =
        tabledata "OG Cue" = RIMD,
        tabledata "OG Exception" = RIMD,
        tabledata "OG Rule Setup" = RIMD,
        codeunit "OG Rule Setup Mgt." = X;
}
