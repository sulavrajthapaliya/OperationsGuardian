codeunit 71008 "OG Rule Error Writer"
{
    TableNo = "OG Rule Setup";

    trigger OnRun()
    begin
        Rec."OG Last Error" := CopyStr(OGErrorText, 1, MaxStrLen(Rec."OG Last Error"));
        Rec.Modify();
    end;

    procedure OGSetError(OGNewErrorText: Text)
    begin
        OGErrorText := OGNewErrorText;
    end;

    var
        OGErrorText: Text;
}
