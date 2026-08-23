codeunit 71007 "OG Rule Runner"
{
    TableNo = "OG Rule Setup";

    trigger OnRun()
    var
        OGRuleProvider: Interface "OG Rule Provider";
        OGExceptionEngine: Codeunit "OG Exception Engine";
    begin
        if IsNullGuid(OGRunId) then
            Error(OGContextMissingErr);

        Clear(OGRuleProvider);
        OGRuleProvider := Rec."OG Provider";
        OGRuleProvider.OGEvaluate(Rec, OGRunId, OGRunAt);
        OGExceptionEngine.OGResolveMissingForRule(Rec."OG Code", OGRunId, OGRunAt);

        Rec."OG Last Run At" := OGRunAt;
        Clear(Rec."OG Last Error");
        Rec.Modify();
    end;

    procedure OGSetContext(OGNewRunId: Guid; OGNewRunAt: DateTime)
    begin
        OGRunId := OGNewRunId;
        OGRunAt := OGNewRunAt;
    end;

    var
        OGRunId: Guid;
        OGRunAt: DateTime;
        OGContextMissingErr: Label 'The Operations Guardian rule execution context was not initialized.';
}
