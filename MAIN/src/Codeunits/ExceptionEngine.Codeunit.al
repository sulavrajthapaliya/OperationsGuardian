codeunit 71000 "OG Exception Engine"
{
    procedure OGRunAll()
    var
        OGRuleSetup: Record "OG Rule Setup";
        OGRuleErrorWriter: Codeunit "OG Rule Error Writer";
        OGRuleRunner: Codeunit "OG Rule Runner";
        OGTelemetry: Codeunit "OG Telemetry";
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
                    OGDetectedCount := OGGetDetectedCount(OGRuleSetup."OG Code", OGRunId);
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

    procedure OGUpsertException(OGRuleSetup: Record "OG Rule Setup"; OGFingerprint: Text[250]; OGSourceTableNo: Integer; OGSourceSystemId: Guid; OGSourceNo: Code[50]; OGDescription: Text[250]; OGDetails: Text[2048]; OGRecommendation: Text[250]; OGRunId: Guid; OGRunAt: DateTime)
    var
        OGException: Record "OG Exception";
    begin
        OGException.SetRange("OG Rule Code", OGRuleSetup."OG Code");
        OGException.SetRange("OG Fingerprint", OGFingerprint);

        if OGException.FindFirst() then begin
            OGException."OG Area" := OGRuleSetup."OG Area";
            OGException."OG Severity" := OGRuleSetup."OG Severity";
            OGException."OG Description" := OGDescription;
            OGException."OG Details" := OGDetails;
            OGException."OG Recommendation" := OGRecommendation;
            OGException."OG Source Table No." := OGSourceTableNo;
            OGException."OG Source SystemId" := OGSourceSystemId;
            OGException."OG Source No." := OGSourceNo;
            OGException."OG Last Detected At" := OGRunAt;
            OGException."OG Last Run Id" := OGRunId;
            OGException."OG Seen Count" += 1;

            if OGException."OG Status" = OGException."OG Status"::"OG Resolved" then begin
                OGException."OG Status" := OGException."OG Status"::"OG Open";
                Clear(OGException."OG Resolved At");
            end;

            if (OGException."OG Status" = OGException."OG Status"::"OG Ignored") and
               (OGException."OG Ignored Until" <> 0DT) and
               (OGException."OG Ignored Until" <= OGRunAt)
            then begin
                OGException."OG Status" := OGException."OG Status"::"OG Open";
                Clear(OGException."OG Ignored Until");
            end;

            OGException.Modify();
            exit;
        end;

        OGException.Init();
        OGException."OG Rule Code" := OGRuleSetup."OG Code";
        OGException."OG Area" := OGRuleSetup."OG Area";
        OGException."OG Severity" := OGRuleSetup."OG Severity";
        OGException."OG Status" := OGException."OG Status"::"OG Open";
        OGException."OG Fingerprint" := OGFingerprint;
        OGException."OG Description" := OGDescription;
        OGException."OG Details" := OGDetails;
        OGException."OG Recommendation" := OGRecommendation;
        OGException."OG Source Table No." := OGSourceTableNo;
        OGException."OG Source SystemId" := OGSourceSystemId;
        OGException."OG Source No." := OGSourceNo;
        OGException."OG Detected At" := OGRunAt;
        OGException."OG Last Detected At" := OGRunAt;
        OGException."OG Last Run Id" := OGRunId;
        OGException."OG Company Name" := CopyStr(CompanyName(), 1, MaxStrLen(OGException."OG Company Name"));
        OGException."OG Seen Count" := 1;
        OGException.Insert(true);
    end;

    procedure OGIgnoreForDays(var OGException: Record "OG Exception"; OGDays: Integer)
    begin
        if OGDays <= 0 then
            Error(OGPositiveDaysErr);

        OGException."OG Status" := OGException."OG Status"::"OG Ignored";
        OGException."OG Ignored Until" := CreateDateTime(Today() + OGDays, Time());
        OGException.Modify(true);
    end;

    procedure OGReopen(var OGException: Record "OG Exception")
    begin
        OGException."OG Status" := OGException."OG Status"::"OG Open";
        Clear(OGException."OG Ignored Until");
        Clear(OGException."OG Resolved At");
        OGException.Modify(true);
    end;

    procedure OGOpenSource(OGException: Record "OG Exception")
    var
        OGPageManagement: Codeunit "Page Management";
        OGRecordRef: RecordRef;
        OGSourceVariant: Variant;
    begin
        if (OGException."OG Source Table No." = 0) or IsNullGuid(OGException."OG Source SystemId") then
            Error(OGNoSourceErr);

        OGRecordRef.Open(OGException."OG Source Table No.");
        if not OGRecordRef.GetBySystemId(OGException."OG Source SystemId") then
            Error(OGSourceNotFoundErr, OGException."OG Source No.");

        OGSourceVariant := OGRecordRef;
        if not OGPageManagement.PageRun(OGSourceVariant) then
            Error(OGPageNotFoundErr, OGException."OG Source No.");
    end;

    procedure OGResolveMissingForRule(OGRuleCode: Code[50]; OGRunId: Guid; OGRunAt: DateTime)
    var
        OGException: Record "OG Exception";
    begin
        OGException.SetRange("OG Rule Code", OGRuleCode);
        OGException.SetFilter("OG Status", '<>%1', OGException."OG Status"::"OG Resolved");
        OGException.SetFilter("OG Last Run Id", '<>%1', OGRunId);

        if OGException.FindSet(true) then
            repeat
                OGException."OG Status" := OGException."OG Status"::"OG Resolved";
                OGException."OG Resolved At" := OGRunAt;
                Clear(OGException."OG Ignored Until");
                OGException.Modify();
            until OGException.Next() = 0;
    end;

    local procedure OGCollectEnabledRuleCodes(var OGRuleCodes: List of [Code[50]])
    var
        OGRuleSetup: Record "OG Rule Setup";
    begin
        OGRuleSetup.SetRange("OG Enabled", true);
        if OGRuleSetup.FindSet() then
            repeat
                OGRuleCodes.Add(OGRuleSetup."OG Code");
            until OGRuleSetup.Next() = 0;
    end;

    local procedure OGGetDetectedCount(OGRuleCode: Code[50]; OGRunId: Guid): Integer
    var
        OGException: Record "OG Exception";
    begin
        OGException.SetRange("OG Rule Code", OGRuleCode);
        OGException.SetRange("OG Last Run Id", OGRunId);
        exit(OGException.Count());
    end;

    var
        OGNoSourceErr: Label 'This exception does not have a source record.';
        OGPageNotFoundErr: Label 'A default page could not be opened for source record %1.', Comment = '%1 source record number/ID';
        OGPositiveDaysErr: Label 'The number of days must be greater than zero.';
        OGSourceNotFoundErr: Label 'The source record %1 no longer exists.', Comment = '%1 source record number/ID';
}
