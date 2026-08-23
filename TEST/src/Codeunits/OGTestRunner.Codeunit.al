codeunit 71102 "OG Test Runner"
{
    Subtype = TestRunner;
    TestIsolation = Function;

    trigger OnRun()
    begin
        Codeunit.Run(Codeunit::"OG Core Tests");
    end;
}
