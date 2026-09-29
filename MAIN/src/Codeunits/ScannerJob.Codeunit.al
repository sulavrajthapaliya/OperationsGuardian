codeunit 71003 "ScannerJob_OG_SRT"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        OGExceptionEngine: Codeunit "ExceptionEngine_OG_SRT";
    begin
        OGExceptionEngine.OGRunAll();
    end;
}
