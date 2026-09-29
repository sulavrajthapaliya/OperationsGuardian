codeunit 71008 "RuleErrorWriter_OG_SRT"
{
    TableNo = "RuleSetup_OG_SRT";

    trigger OnRun()
    begin
        Rec."Last Error" := CopyStr(OGErrorText, 1, MaxStrLen(Rec."Last Error"));
        Rec.Modify();
    end;

    procedure OGSetError(OGNewErrorText: Text)
    begin
        OGErrorText := OGNewErrorText;
    end;

    var
        OGErrorText: Text;
}
