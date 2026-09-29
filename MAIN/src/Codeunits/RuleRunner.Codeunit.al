codeunit 71007 "RuleRunner_OG_SRT"
{
    TableNo = "RuleSetup_OG_SRT";

    trigger OnRun()
    var
        OGExceptionEngine: Codeunit "ExceptionEngine_OG_SRT";
        OGRuleProvider: Interface "RuleProvider_OG_SRT";
    begin
        if IsNullGuid(OGRunId) then
            Error(OGContextMissingErr);

        Clear(OGRuleProvider);
        OGRuleProvider := Rec."Provider";
        OGRuleProvider.OGEvaluate(Rec, OGRunId, OGRunAt);
        OGExceptionEngine.OGResolveMissingForRule(Rec."Code", OGRunId, OGRunAt);

        Rec."Last Run At" := OGRunAt;
        Clear(Rec."Last Error");
        Rec.Modify();
    end;

    procedure OGSetContext(OGNewRunId: Guid; OGNewRunAt: DateTime)
    begin
        OGRunId := OGNewRunId;
        OGRunAt := OGNewRunAt;
    end;

    var
        OGRunAt: DateTime;
        OGRunId: Guid;
        OGContextMissingErr: Label 'The Operations Guardian rule execution context was not initialized.';
}
