pageextension 71000 "OG Business Manager RC" extends "Business Manager Role Center"
{
    layout
    {
        addfirst(rolecenter)
        {
            part(OGOperationsGuardian; "OG Role Center Cues")
            {
                ApplicationArea = All;
                Caption = 'Operations Guardian';
            }
        }
    }
}
