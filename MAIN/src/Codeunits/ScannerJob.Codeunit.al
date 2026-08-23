codeunit 71003 "OG Scanner Job"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        OGExceptionEngine: Codeunit "OG Exception Engine";
    begin
        OGExceptionEngine.OGRunAll();
    end;
}
