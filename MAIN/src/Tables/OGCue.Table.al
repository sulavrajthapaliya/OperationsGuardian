table 71002 "OG Cue"
{
    Caption = 'Operations Guardian Cue';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "OG Primary Key"; Integer)
        {
            Caption = 'Primary Key';
            DataClassification = SystemMetadata;
        }
        field(2; "OG Open Exceptions"; Integer)
        {
            Caption = 'Open Exceptions';
            FieldClass = FlowField;
            CalcFormula = count("OG Exception" where("OG Status" = const("OG Open")));
        }
        field(3; "OG Critical Exceptions"; Integer)
        {
            Caption = 'Critical Exceptions';
            FieldClass = FlowField;
            CalcFormula = count("OG Exception" where("OG Status" = const("OG Open"), "OG Severity" = const("OG Critical")));
        }
        field(4; "OG Warning Exceptions"; Integer)
        {
            Caption = 'Warning Exceptions';
            FieldClass = FlowField;
            CalcFormula = count("OG Exception" where("OG Status" = const("OG Open"), "OG Severity" = const("OG Warning")));
        }
        field(5; "OG Ignored Exceptions"; Integer)
        {
            Caption = 'Ignored Exceptions';
            FieldClass = FlowField;
            CalcFormula = count("OG Exception" where("OG Status" = const("OG Ignored")));
        }
    }

    keys
    {
        key(OGPK; "OG Primary Key")
        {
            Clustered = true;
        }
    }
}
