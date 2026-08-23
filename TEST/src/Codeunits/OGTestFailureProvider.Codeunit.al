codeunit 71100 "OG Test Failure Provider" implements "OG Rule Provider"
{
    procedure OGEvaluate(OGRuleSetup: Record "OG Rule Setup"; OGRunId: Guid; OGRunAt: DateTime)
    var
        OGExceptionEngine: Codeunit "OG Exception Engine";
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
