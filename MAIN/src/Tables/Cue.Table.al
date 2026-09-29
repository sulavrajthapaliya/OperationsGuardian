table 71002 "Cue_OG_SRT"
{
    Caption = 'Operations Guardian Cue';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Primary Key"; Integer)
        {
            Caption = 'Primary Key';
            DataClassification = SystemMetadata;
        }
        field(2; "Open Exceptions"; Integer)
        {
            CalcFormula = count("Exception_OG_SRT" where(Status = const("Open")));
            Caption = 'Open Exceptions';
            FieldClass = FlowField;
        }
        field(3; "Critical Exceptions"; Integer)
        {
            CalcFormula = count("Exception_OG_SRT" where(Status = const("Open"), "Severity" = const("Critical")));
            Caption = 'Critical Exceptions';
            FieldClass = FlowField;
        }
        field(4; "Warning Exceptions"; Integer)
        {
            CalcFormula = count("Exception_OG_SRT" where(Status = const("Open"), "Severity" = const("Warning")));
            Caption = 'Warning Exceptions';
            FieldClass = FlowField;
        }
        field(5; "Ignored Exceptions"; Integer)
        {
            CalcFormula = count("Exception_OG_SRT" where(Status = const("Ignored")));
            Caption = 'Ignored Exceptions';
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}
