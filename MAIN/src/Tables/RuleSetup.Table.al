table 71001 "RuleSetup_OG_SRT"
{
    Caption = 'Operations Guardian Rule Setup';
    DataClassification = CustomerContent;
    DrillDownPageId = "RuleSetup_OG_SRT";
    LookupPageId = "RuleSetup_OG_SRT";

    fields
    {
        field(1; "Code"; Code[50])
        {
            Caption = 'Code';
            DataClassification = SystemMetadata;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(3; "Area"; Enum "ExceptionArea_OG_SRT")
        {
            Caption = 'Area';
            DataClassification = SystemMetadata;
        }
        field(4; Severity; Enum "ExceptionSeverity_OG_SRT")
        {
            Caption = 'Severity';
            DataClassification = SystemMetadata;
        }
        field(5; Enabled; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = SystemMetadata;
        }
        field(6; Provider; Enum "RuleProvider_OG_SRT")
        {
            Caption = 'Provider';
            DataClassification = SystemMetadata;
        }
        field(7; "Threshold Days"; Integer)
        {
            Caption = 'Threshold (Days)';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            begin
                if "Threshold Days" < 0 then
                    Error(OGThresholdErr);
            end;
        }
        field(8; "Last Run At"; DateTime)
        {
            Caption = 'Last Run At';
            DataClassification = SystemMetadata;
            Editable = false;
        }
        field(9; "Last Error"; Text[2048])
        {
            Caption = 'Last Error';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(OGPK; "Code")
        {
            Clustered = true;
        }
    }

    var
        OGThresholdErr: Label 'Threshold Days cannot be negative.';
}
