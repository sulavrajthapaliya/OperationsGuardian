codeunit 71100 "OG Test Failure Provider" implements "RuleProvider_OG_SRT"
{
    procedure OGEvaluate(OGRuleSetup: Record "RuleSetup_OG_SRT"; OGRunId: Guid; OGRunAt: DateTime)
    var
        OGExceptionEngine: Codeunit "ExceptionEngine_OG_SRT";
        OGEmptyGuid: Guid;
    begin
        Clear(OGEmptyGuid);
        OGExceptionEngine.OGUpsertException(
            OGRuleSetup,
            'TEST-PARTIAL-WRITE',
            0,
            OGEmptyGuid,
            '',
            'This partial exception must be rolled back.',
            '',
            '',
            OGRunId,
            OGRunAt);

        Error(OGExpectedFailureErr);
    end;

    var
        OGExpectedFailureErr: Label 'Intentional Operations Guardian test provider failure.';
}
