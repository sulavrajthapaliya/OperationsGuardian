permissionset 71001 "OG ADMIN"
{
    Assignable = true;
    Caption = 'Operations Guardian Administrator';
    IncludedPermissionSets = "OG USER";

    Permissions =
        tabledata "OG Exception" = RIMD,
        tabledata "OG Rule Setup" = RIMD,
        tabledata "OG Cue" = RIMD,
        codeunit "OG Rule Setup Mgt." = X;
}
