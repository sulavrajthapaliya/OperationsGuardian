codeunit 71000 "ExceptionEngine_OG_SRT"
{
    procedure OGRunAll()
    var
        OGRuleSetup: Record "RuleSetup_OG_SRT";
        OGRuleErrorWriter: Codeunit "RuleErrorWriter_OG_SRT";
        OGRuleRunner: Codeunit "RuleRunner_OG_SRT";
        OGTelemetry: Codeunit "Telemetry_OG_SRT";
        OGRuleCode: Code[50];
        OGRuleStartedAt: DateTime;
        OGRunAt: DateTime;
        OGScanStartedAt: DateTime;
        OGRunId: Guid;
        OGDetectedCount: Integer;
        OGFailureCount: Integer;
        OGSuccessCount: Integer;
        OGRuleCodes: List of [Code[50]];
        OGLastError: Text;
    begin
        OGRunId := CreateGuid();
        OGRunAt := CurrentDateTime();
        OGScanStartedAt := OGRunAt;
        OGTelemetry.OGLogScanStarted(OGRunId);

        OGCollectEnabledRuleCodes(OGRuleCodes);

        foreach OGRuleCode in OGRuleCodes do
            if OGRuleSetup.Get(OGRuleCode) then begin
                OGRuleStartedAt := CurrentDateTime();
                Clear(OGRuleRunner);
                OGRuleRunner.OGSetContext(OGRunId, OGRunAt);
                ClearLastError();

                if OGRuleRunner.Run(OGRuleSetup) then begin
                    OGSuccessCount += 1;
                    OGDetectedCount := OGGetDetectedCount(OGRuleSetup.Code, OGRunId);
                    OGTelemetry.OGLogRuleCompleted(OGRuleSetup, OGRunId, CurrentDateTime() - OGRuleStartedAt, OGDetectedCount);
                end else begin
                    OGLastError := GetLastErrorText();
                    Clear(OGRuleErrorWriter);
                    OGRuleErrorWriter.OGSetError(OGLastError);
                    if not OGRuleErrorWriter.Run(OGRuleSetup) then
                        ClearLastError();

                    OGFailureCount += 1;
                    OGTelemetry.OGLogRuleFailed(OGRuleSetup, OGRunId, CurrentDateTime() - OGRuleStartedAt);
                end;
            end;

        OGTelemetry.OGLogScanCompleted(OGRunId, CurrentDateTime() - OGScanStartedAt, OGSuccessCount, OGFailureCount);
    end;

    procedure OGUpsertException(OGRuleSetup: Record "RuleSetup_OG_SRT"; OGFingerprint: Text[250]; OGSourceTableNo: Integer; OGSourceSystemId: Guid; OGSourceNo: Code[50]; OGDescription: Text[250]; OGDetails: Text[2048]; OGRecommendation: Text[250]; OGRunId: Guid; OGRunAt: DateTime)
    var
        OGException: Record "Exception_OG_SRT";
    begin
        OGException.SetRange("Rule Code", OGRuleSetup.Code);
        OGException.SetRange("Fingerprint", OGFingerprint);

        if OGException.FindFirst() then begin
            OGException."Area" := OGRuleSetup."Area";
            OGException."Severity" := OGRuleSetup."Severity";
            OGException."Description" := OGDescription;
            OGException."Details" := OGDetails;
            OGException."Recommendation" := OGRecommendation;
            OGException."Source Table No." := OGSourceTableNo;
            OGException."Source SystemId" := OGSourceSystemId;
            OGException."Source No." := OGSourceNo;
            OGException."Last Detected At" := OGRunAt;
            OGException."Last Run Id" := OGRunId;
            OGException."Seen Count" += 1;

            if OGException."Status" = OGException."Status"::"Resolved" then begin
                OGException."Status" := OGException."Status"::"Open";
                Clear(OGException."Resolved At");
            end;

            if (OGException."Status" = OGException."Status"::"Ignored") and
               (OGException."Ignored Until" <> 0DT) and
               (OGException."Ignored Until" <= OGRunAt)
            then begin
                OGException."Status" := OGException."Status"::"Open";
                Clear(OGException."Ignored Until");
            end;

            OGException.Modify();
            exit;
        end;

        OGException.Init();
        OGException."Rule Code" := OGRuleSetup.Code;
        OGException."Area" := OGRuleSetup."Area";
        OGException."Severity" := OGRuleSetup."Severity";
        OGException."Status" := OGException."Status"::"Open";
        OGException."Fingerprint" := OGFingerprint;
        OGException."Description" := OGDescription;
        OGException."Details" := OGDetails;
        OGException."Recommendation" := OGRecommendation;
        OGException."Source Table No." := OGSourceTableNo;
        OGException."Source SystemId" := OGSourceSystemId;
        OGException."Source No." := OGSourceNo;
        OGException."Detected At" := OGRunAt;
        OGException."Last Detected At" := OGRunAt;
        OGException."Last Run Id" := OGRunId;
        OGException."Company Name" := CopyStr(CompanyName(), 1, MaxStrLen(OGException."Company Name"));
        OGException."Seen Count" := 1;
        OGException.Insert(true);
    end;

    procedure OGIgnoreForDays(var OGException: Record "Exception_OG_SRT"; OGDays: Integer)
    begin
        if OGDays <= 0 then
            Error(OGPositiveDaysErr);

        OGException."Status" := OGException."Status"::"Ignored";
        OGException."Ignored Until" := CreateDateTime(Today() + OGDays, Time());
        OGException.Modify(true);
    end;

    procedure OGReopen(var OGException: Record "Exception_OG_SRT")
    begin
        OGException."Status" := OGException."Status"::"Open";
        Clear(OGException."Ignored Until");
        Clear(OGException."Resolved At");
        OGException.Modify(true);
    end;

    procedure OGOpenSource(OGException: Record "Exception_OG_SRT")
    var
        OGPageManagement: Codeunit "Page Management";
        OGRecordRef: RecordRef;
        OGSourceVariant: Variant;
    begin
        if (OGException."Source Table No." = 0) or IsNullGuid(OGException."Source SystemId") then
            Error(OGNoSourceErr);

        OGRecordRef.Open(OGException."Source Table No.");
        if not OGRecordRef.GetBySystemId(OGException."Source SystemId") then
            Error(OGSourceNotFoundErr, OGException."Source No.");

        OGSourceVariant := OGRecordRef;
        if not OGPageManagement.PageRun(OGSourceVariant) then
            Error(OGPageNotFoundErr, OGException."Source No.");
    end;

    procedure OGResolveMissingForRule(OGRuleCode: Code[50]; OGRunId: Guid; OGRunAt: DateTime)
    var
        OGException: Record "Exception_OG_SRT";
    begin
        OGException.SetRange("Rule Code", OGRuleCode);
        OGException.SetFilter("Status", '<>%1', OGException."Status"::"Resolved");
        OGException.SetFilter("Last Run Id", '<>%1', OGRunId);

        if OGException.FindSet(true) then
            repeat
                OGException."Status" := OGException."Status"::"Resolved";
                OGException."Resolved At" := OGRunAt;
                Clear(OGException."Ignored Until");
                OGException.Modify();
            until OGException.Next() = 0;
    end;

    local procedure OGCollectEnabledRuleCodes(var OGRuleCodes: List of [Code[50]])
    var
        OGRuleSetup: Record "RuleSetup_OG_SRT";
    begin
        OGRuleSetup.SetRange("Enabled", true);
        if OGRuleSetup.FindSet() then
            repeat
                OGRuleCodes.Add(OGRuleSetup.Code);
            until OGRuleSetup.Next() = 0;
    end;

    local procedure OGGetDetectedCount(OGRuleCode: Code[50]; OGRunId: Guid): Integer
    var
        OGException: Record "Exception_OG_SRT";
    begin
        OGException.SetRange("Rule Code", OGRuleCode);
        OGException.SetRange("Last Run Id", OGRunId);
        exit(OGException.Count());
    end;

    var
        OGNoSourceErr: Label 'This exception does not have a source record.';
        OGPageNotFoundErr: Label 'A default page could not be opened for source record %1.', Comment = '%1 source record number/ID';
        OGPositiveDaysErr: Label 'The number of days must be greater than zero.';
        OGSourceNotFoundErr: Label 'The source record %1 no longer exists.', Comment = '%1 source record number/ID';
}
