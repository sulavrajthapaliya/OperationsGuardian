table 71001 "OG Rule Setup"
{
    Caption = 'Operations Guardian Rule Setup';
    DataClassification = CustomerContent;
    DrillDownPageId = "OG Rule Setup";
    LookupPageId = "OG Rule Setup";

    fields
    {
        field(1; "OG Code"; Code[50])
        {
            Caption = 'Code';
            DataClassification = SystemMetadata;
        }
        field(2; "OG Description"; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(3; "OG Area"; Enum "OG Exception Area")
        {
            Caption = 'Area';
            DataClassification = SystemMetadata;
        }
        field(4; "OG Severity"; Enum "OG Exception Severity")
        {
            Caption = 'Severity';
            DataClassification = SystemMetadata;
        }
        field(5; "OG Enabled"; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = SystemMetadata;
        }
        field(6; "OG Provider"; Enum "OG Rule Provider")
        {
            Caption = 'Provider';
            DataClassification = SystemMetadata;
        }
        field(7; "OG Threshold Days"; Integer)
        {
            Caption = 'Threshold (Days)';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                if "OG Threshold Days" < 0 then
                    Error(OGThresholdErr);
            end;
        }
        field(8; "OG Last Run At"; DateTime)
        {
            Caption = 'Last Run At';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(9; "OG Last Error"; Text[2048])
        {
            Caption = 'Last Error';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(OGPK; "OG Code")
        {
            Clustered = true;
        }
    }

    var
        OGThresholdErr: Label 'Threshold Days cannot be negative.';
}
