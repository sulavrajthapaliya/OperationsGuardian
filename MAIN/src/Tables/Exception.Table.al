table 71000 "OG Exception"
{
    Caption = 'Operations Guardian Exception';
    DataClassification = CustomerContent;
    DrillDownPageId = "OG Exception Inbox";
    LookupPageId = "OG Exception Inbox";

    fields
    {
        field(1; "OG Entry No."; BigInteger)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
        }
        field(2; "OG Rule Code"; Code[50])
        {
            Caption = 'Rule Code';
            DataClassification = SystemMetadata;
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
        field(5; "OG Status"; Enum "OG Exception Status")
        {
            Caption = 'Status';
            DataClassification = SystemMetadata;
        }
        field(6; "OG Fingerprint"; Text[250])
        {
            Caption = 'Fingerprint';
            DataClassification = SystemMetadata;
        }
        field(7; "OG Description"; Text[250])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(8; "OG Details"; Text[2048])
        {
            Caption = 'Details';
            DataClassification = CustomerContent;
        }
        field(9; "OG Recommendation"; Text[250])
        {
            Caption = 'Recommendation';
            DataClassification = CustomerContent;
        }
        field(10; "OG Source Table No."; Integer)
        {
            Caption = 'Source Table No.';
            DataClassification = SystemMetadata;
        }
        field(11; "OG Source SystemId"; Guid)
        {
            Caption = 'Source SystemId';
            DataClassification = SystemMetadata;
        }
        field(12; "OG Source No."; Code[50])
        {
            Caption = 'Source No.';
            DataClassification = CustomerContent;
        }
        field(13; "OG Detected At"; DateTime)
        {
            Caption = 'Detected At';
            DataClassification = SystemMetadata;
        }
        field(14; "OG Last Detected At"; DateTime)
        {
            Caption = 'Last Detected At';
            DataClassification = SystemMetadata;
        }
        field(15; "OG Resolved At"; DateTime)
        {
            Caption = 'Resolved At';
            DataClassification = SystemMetadata;
        }
        field(16; "OG Ignored Until"; DateTime)
        {
            Caption = 'Ignored Until';
            DataClassification = SystemMetadata;
        }
        field(17; "OG Last Run Id"; Guid)
        {
            Caption = 'Last Run Id';
            DataClassification = SystemMetadata;
        }
        field(18; "OG Company Name"; Text[30])
        {
            Caption = 'Company Name';
            DataClassification = OrganizationIdentifiableInformation;
        }
        field(19; "OG Seen Count"; Integer)
        {
            Caption = 'Seen Count';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(OGPK; "OG Entry No.")
        {
            Clustered = true;
        }
        key(OGRuleFingerprint; "OG Rule Code", "OG Fingerprint")
        {
            Unique = true;
        }
        key(OGStatusSeverityDate; "OG Status", "OG Severity", "OG Last Detected At")
        {
        }
    }
}
