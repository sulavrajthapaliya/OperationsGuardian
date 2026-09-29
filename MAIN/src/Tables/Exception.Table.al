table 71000 "Exception_OG_SRT"
{
    Caption = 'Operations Guardian Exception';
    DataClassification = CustomerContent;
    DrillDownPageId = "ExceptionInbox_OG_SRT";
    LookupPageId = "ExceptionInbox_OG_SRT";

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
        }
        field(2; "Rule Code"; Code[50])
        {
            Caption = 'Rule Code';
            DataClassification = SystemMetadata;
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
        field(5; Status; Enum "ExceptionStatus_OG_SRT")
        {
            Caption = 'Status';
            DataClassification = SystemMetadata;
        }
        field(6; Fingerprint; Text[250])
        {
            Caption = 'Fingerprint';
            DataClassification = SystemMetadata;
        }
        field(7; Description; Text[250])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(8; Details; Text[2048])
        {
            Caption = 'Details';
            DataClassification = CustomerContent;
        }
        field(9; Recommendation; Text[250])
        {
            Caption = 'Recommendation';
            DataClassification = CustomerContent;
        }
        field(10; "Source Table No."; Integer)
        {
            Caption = 'Source Table No.';
            DataClassification = SystemMetadata;
        }
        field(11; "Source SystemId"; Guid)
        {
            Caption = 'Source SystemId';
            DataClassification = SystemMetadata;
        }
        field(12; "Source No."; Code[50])
        {
            Caption = 'Source No.';
            DataClassification = CustomerContent;
        }
        field(13; "Detected At"; DateTime)
        {
            Caption = 'Detected At';
            DataClassification = SystemMetadata;
        }
        field(14; "Last Detected At"; DateTime)
        {
            Caption = 'Last Detected At';
            DataClassification = SystemMetadata;
        }
        field(15; "Resolved At"; DateTime)
        {
            Caption = 'Resolved At';
            DataClassification = SystemMetadata;
        }
        field(16; "Ignored Until"; DateTime)
        {
            Caption = 'Ignored Until';
            DataClassification = SystemMetadata;
        }
        field(17; "Last Run Id"; Guid)
        {
            Caption = 'Last Run Id';
            DataClassification = SystemMetadata;
        }
        field(18; "Company Name"; Text[30])
        {
            Caption = 'Company Name';
            DataClassification = OrganizationIdentifiableInformation;
        }
        field(19; "Seen Count"; Integer)
        {
            Caption = 'Seen Count';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(OGPK; "Entry No.")
        {
            Clustered = true;
        }
        key(OGRuleFingerprint; "Rule Code", "Fingerprint")
        {
            Unique = true;
        }
        key(OGStatusSeverityDate; "Status", "Severity", "Last Detected At")
        {
        }
    }
}
