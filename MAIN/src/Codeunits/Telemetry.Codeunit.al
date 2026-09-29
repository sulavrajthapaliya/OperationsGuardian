codeunit 71006 "Telemetry_OG_SRT"
{
    procedure OGLogScanStarted(OGRunId: Guid)
    var
        OGDimensions: Dictionary of [Text, Text];
    begin
        OGDimensions.Add('runId', Format(OGRunId));
        OGDimensions.Add('result', 'started');

        Session.LogMessage(
            'OG0001',
            'Operations Guardian scan started.',
            Verbosity::Normal,
            DataClassification::SystemMetadata,
            TelemetryScope::ExtensionPublisher,
            OGDimensions);
    end;

    procedure OGLogRuleCompleted(OGRuleSetup: Record "RuleSetup_OG_SRT"; OGRunId: Guid; OGDuration: Duration; OGDetectedCount: Integer)
    var
        OGDimensions: Dictionary of [Text, Text];
    begin
        OGAddCommonRuleDimensions(OGDimensions, OGRuleSetup, OGRunId);
        OGDimensions.Add('result', 'success');
        OGDimensions.Add('duration', Format(OGDuration));
        OGDimensions.Add('detectedCount', Format(OGDetectedCount));

        Session.LogMessage(
            'OG0002',
            'Operations Guardian rule evaluation completed.',
            Verbosity::Normal,
            DataClassification::SystemMetadata,
            TelemetryScope::ExtensionPublisher,
            OGDimensions);
    end;

    procedure OGLogRuleFailed(OGRuleSetup: Record "RuleSetup_OG_SRT"; OGRunId: Guid; OGDuration: Duration)
    var
        OGDimensions: Dictionary of [Text, Text];
    begin
        OGAddCommonRuleDimensions(OGDimensions, OGRuleSetup, OGRunId);
        OGDimensions.Add('result', 'failed');
        OGDimensions.Add('duration', Format(OGDuration));

        // Deliberately do not emit GetLastErrorText() because provider errors can contain customer content.
        Session.LogMessage(
            'OG0003',
            'Operations Guardian rule evaluation failed.',
            Verbosity::Warning,
            DataClassification::SystemMetadata,
            TelemetryScope::ExtensionPublisher,
            OGDimensions);
    end;

    procedure OGLogScanCompleted(OGRunId: Guid; OGDuration: Duration; OGSuccessCount: Integer; OGFailureCount: Integer)
    var
        OGDimensions: Dictionary of [Text, Text];
    begin
        OGDimensions.Add('runId', Format(OGRunId));
        OGDimensions.Add('duration', Format(OGDuration));
        OGDimensions.Add('successCount', Format(OGSuccessCount));
        OGDimensions.Add('failureCount', Format(OGFailureCount));
        if OGFailureCount = 0 then
            OGDimensions.Add('result', 'success')
        else
            OGDimensions.Add('result', 'partialFailure');

        Session.LogMessage(
            'OG0004',
            'Operations Guardian scan completed.',
            Verbosity::Normal,
            DataClassification::SystemMetadata,
            TelemetryScope::ExtensionPublisher,
            OGDimensions);
    end;

    local procedure OGAddCommonRuleDimensions(var OGDimensions: Dictionary of [Text, Text]; OGRuleSetup: Record "RuleSetup_OG_SRT"; OGRunId: Guid)
    begin
        OGDimensions.Add('runId', Format(OGRunId));
        OGDimensions.Add('ruleCode', Format(OGRuleSetup."Code"));
        OGDimensions.Add('provider', Format(OGRuleSetup."Provider"));
        OGDimensions.Add('severity', Format(OGRuleSetup."Severity"));
        OGDimensions.Add('area', Format(OGRuleSetup."Area"));
    end;
}
