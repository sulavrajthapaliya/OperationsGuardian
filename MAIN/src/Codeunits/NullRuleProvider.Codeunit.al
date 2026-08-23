codeunit 71004 "OG Null Rule Provider" implements "OG Rule Provider"
{
    procedure OGEvaluate(OGRuleSetup: Record "OG Rule Setup"; OGRunId: Guid; OGRunAt: DateTime)
    begin
        // Intentionally empty. Used as the default/unknown implementation.
    end;
}
