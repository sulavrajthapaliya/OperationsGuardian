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
            CalcFormula = count("OG Exception" where("OG Status" = const("OG Open")));
            Caption = 'Open Exceptions';
            FieldClass = FlowField;
        }
        field(3; "OG Critical Exceptions"; Integer)
        {
            CalcFormula = count("OG Exception" where("OG Status" = const("OG Open"), "OG Severity" = const("OG Critical")));
            Caption = 'Critical Exceptions';
            FieldClass = FlowField;
        }
        field(4; "OG Warning Exceptions"; Integer)
        {
            CalcFormula = count("OG Exception" where("OG Status" = const("OG Open"), "OG Severity" = const("OG Warning")));
            Caption = 'Warning Exceptions';
            FieldClass = FlowField;
        }
        field(5; "OG Ignored Exceptions"; Integer)
        {
            CalcFormula = count("OG Exception" where("OG Status" = const("OG Ignored")));
            Caption = 'Ignored Exceptions';
            FieldClass = FlowField;
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
