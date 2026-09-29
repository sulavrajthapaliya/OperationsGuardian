interface "RuleProvider_OG_SRT"
{
    procedure OGEvaluate(OGRuleSetup: Record "RuleSetup_OG_SRT"; OGRunId: Guid; OGRunAt: DateTime);
}
