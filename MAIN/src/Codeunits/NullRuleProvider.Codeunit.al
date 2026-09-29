codeunit 71004 "NullRuleProvider_OG_SRT" implements "RuleProvider_OG_SRT"
{
    procedure OGEvaluate(OGRuleSetup: Record "RuleSetup_OG_SRT"; OGRunId: Guid; OGRunAt: DateTime)
    begin
        // Intentionally empty. Used as the default/unknown implementation.
    end;
}
