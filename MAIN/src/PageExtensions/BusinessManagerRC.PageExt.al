pageextension 71000 "BusinessManagerRC_OG_SRT" extends "Business Manager Role Center"
{
    layout
    {
        addfirst(rolecenter)
        {
            part(OGOperationsGuardian; "RoleCenterCues_OG_SRT")
            {
                ApplicationArea = All;
                Caption = 'Operations Guardian';
            }
        }
    }
}
