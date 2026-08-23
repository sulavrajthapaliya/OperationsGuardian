codeunit 71101 "OG Core Tests"
{
    RequiredTestIsolation = Function;
    Subtype = Test;

    [Test]
    procedure OGDefaultsCreateEightRules()
    var
        OGRuleSetup: Record "OG Rule Setup";
        OGRuleSetupMgt: Codeunit "OG Rule Setup Mgt.";
    begin
        OGRuleSetup.DeleteAll();

        OGRuleSetupMgt.OGEnsureDefaults();

        OGAssertEqualInteger(8, OGRuleSetup.Count(), 'Default rule count');
        OGAssertTrue(OGRuleSetup.Get('NO-SERIES-EXHAUSTION'), 'NO-SERIES-EXHAUSTION should be created.');
    end;

    [Test]
    procedure OGEnsureDefaultsPreservesExistingConfiguration()
    var
        OGRuleSetup: Record "OG Rule Setup";
        OGRuleSetupMgt: Codeunit "OG Rule Setup Mgt.";
    begin
        OGRuleSetup.DeleteAll();
        OGRuleSetupMgt.OGEnsureDefaults();

        OGRuleSetup.Get('SALES-OVERDUE');
        OGRuleSetup."OG Threshold Days" := 99;
        OGRuleSetup.Modify();

        OGRuleSetupMgt.OGEnsureDefaults();

        OGRuleSetup.Get('SALES-OVERDUE');
        OGAssertEqualInteger(99, OGRuleSetup."OG Threshold Days", 'Existing rule threshold must not be overwritten.');
    end;

    [Test]
    procedure OGUpsertUsesRuleAndFingerprintAsUniqueIdentity()
    var
        OGException: Record "OG Exception";
        OGRuleSetup: Record "OG Rule Setup";
        OGExceptionEngine: Codeunit "OG Exception Engine";
        OGRunAt: DateTime;
        OGEmptyGuid: Guid;
        OGRunId: Guid;
    begin
        OGRuleSetup.DeleteAll();
        OGException.DeleteAll();
        OGInsertTestRule(OGRuleSetup, 'OGTEST-UPSERT', "OG Rule Provider"::"OG None");

        OGRunId := CreateGuid();
        OGRunAt := CurrentDateTime();
        Clear(OGEmptyGuid);

        OGExceptionEngine.OGUpsertException(OGRuleSetup, 'SAME-FINGERPRINT', 0, OGEmptyGuid, '', 'Test exception', '', '', OGRunId, OGRunAt);
        OGExceptionEngine.OGUpsertException(OGRuleSetup, 'SAME-FINGERPRINT', 0, OGEmptyGuid, '', 'Test exception updated', '', '', OGRunId, OGRunAt);

        OGException.SetRange("OG Rule Code", OGRuleSetup."OG Code");
        OGException.SetRange("OG Fingerprint", 'SAME-FINGERPRINT');
        OGAssertEqualInteger(1, OGException.Count(), 'Upsert must not create duplicates.');
        OGException.FindFirst();
        OGAssertEqualInteger(2, OGException."OG Seen Count", 'Seen count must increment on repeated detection.');
    end;

    [Test]
    procedure OGFailedRuleRollsBackAndDoesNotStopFollowingRule()
    var
        OGException: Record "OG Exception";
        OGRuleSetup: Record "OG Rule Setup";
        OGExceptionEngine: Codeunit "OG Exception Engine";
    begin
        OGRuleSetup.DeleteAll();
        OGException.DeleteAll();

        OGInsertTestRule(OGRuleSetup, 'A-FAIL', "OG Rule Provider"::"OG Test Failure");
        OGInsertTestRule(OGRuleSetup, 'Z-SUCCESS', "OG Rule Provider"::"OG None");

        OGExceptionEngine.OGRunAll();

        OGRuleSetup.Get('A-FAIL');
        OGAssertTrue(OGRuleSetup."OG Last Error" <> '', 'Failed rule should retain its last error.');
        OGAssertTrue(StrPos(OGRuleSetup."OG Last Error", 'Intentional Operations Guardian') > 0, 'Expected provider error should be stored.');
        OGAssertTrue(OGRuleSetup."OG Last Run At" = 0DT, 'Failed rule should not update Last Run At.');

        OGException.SetRange("OG Rule Code", 'A-FAIL');
        OGAssertEqualInteger(0, OGException.Count(), 'Partial exception writes from a failed rule must roll back.');

        OGRuleSetup.Get('Z-SUCCESS');
        OGAssertTrue(OGRuleSetup."OG Last Run At" <> 0DT, 'A later rule should still run after a previous rule fails.');
        OGAssertTrue(OGRuleSetup."OG Last Error" = '', 'Successful rule should have no last error.');
    end;

    [Test]
    procedure OGSuccessfulEmptyScanResolvesPreviousException()
    var
        OGException: Record "OG Exception";
        OGRuleSetup: Record "OG Rule Setup";
        OGExceptionEngine: Codeunit "OG Exception Engine";
        OGEmptyGuid: Guid;
        OGOldRunId: Guid;
    begin
        OGRuleSetup.DeleteAll();
        OGException.DeleteAll();
        OGInsertTestRule(OGRuleSetup, 'OGTEST-RESOLVE', "OG Rule Provider"::"OG None");

        OGOldRunId := CreateGuid();
        Clear(OGEmptyGuid);
        OGExceptionEngine.OGUpsertException(OGRuleSetup, 'RESOLVE-ME', 0, OGEmptyGuid, '', 'Resolve me', '', '', OGOldRunId, CurrentDateTime());

        OGExceptionEngine.OGRunAll();

        OGException.SetRange("OG Rule Code", 'OGTEST-RESOLVE');
        OGException.SetRange("OG Fingerprint", 'RESOLVE-ME');
        OGException.FindFirst();
        OGAssertTrue(OGException."OG Status" = OGException."OG Status"::"OG Resolved", 'Missing exception should be resolved after a successful rule run.');
        OGAssertTrue(OGException."OG Resolved At" <> 0DT, 'Resolved At should be populated.');
    end;

    [Test]
    procedure OGNumberSeriesWarningCreatesException()
    var
        OGNoSeries: Record "No. Series";
        OGNoSeriesLine: Record "No. Series Line";
        OGException: Record "OG Exception";
        OGRuleSetup: Record "OG Rule Setup";
        OGExceptionEngine: Codeunit "OG Exception Engine";
        OGSeriesCode: Code[20];
    begin
        OGRuleSetup.DeleteAll();
        OGException.DeleteAll();
        OGInsertTestRule(OGRuleSetup, 'NO-SERIES-EXHAUSTION', "OG Rule Provider"::"OG System");

        OGSeriesCode := OGGetUniqueSeriesCode();
        OGNoSeries.Init();
        OGNoSeries.Code := OGSeriesCode;
        OGNoSeries.Description := 'Operations Guardian automated test';
        OGNoSeries.Insert();

        OGNoSeriesLine.Init();
        OGNoSeriesLine."Series Code" := OGSeriesCode;
        OGNoSeriesLine."Line No." := 10000;
        OGNoSeriesLine."Starting Date" := 0D;
        OGNoSeriesLine."Starting No." := 'OG0001';
        OGNoSeriesLine."Ending No." := 'OG9999';
        OGNoSeriesLine."Warning No." := 'OG9000';
        OGNoSeriesLine."Increment-by No." := 1;
        OGNoSeriesLine."Last No. Used" := 'OG9000';
        OGNoSeriesLine.Open := true;
        OGNoSeriesLine.Insert();

        OGExceptionEngine.OGRunAll();

        OGException.SetRange("OG Rule Code", 'NO-SERIES-EXHAUSTION');
        OGException.SetRange("OG Source No.", OGSeriesCode);
        OGAssertEqualInteger(1, OGException.Count(), 'Number series at its warning number should create one exception.');
        OGException.FindFirst();
        OGAssertTrue(OGException."OG Status" = OGException."OG Status"::"OG Open", 'Number series exception should be open.');
    end;

    local procedure OGInsertTestRule(var OGRuleSetup: Record "OG Rule Setup"; OGCode: Code[50]; OGProvider: Enum "OG Rule Provider")
    begin
        OGRuleSetup.Init();
        OGRuleSetup."OG Code" := OGCode;
        OGRuleSetup."OG Description" := CopyStr('Automated test rule ' + OGCode, 1, MaxStrLen(OGRuleSetup."OG Description"));
        OGRuleSetup."OG Area" := "OG Exception Area"::"OG System";
        OGRuleSetup."OG Severity" := "OG Exception Severity"::"OG Warning";
        OGRuleSetup."OG Enabled" := true;
        OGRuleSetup."OG Provider" := OGProvider;
        OGRuleSetup.Insert();
    end;

    local procedure OGGetUniqueSeriesCode(): Code[20]
    var
        OGSeriesCode: Code[20];
        OGGuidText: Text;
    begin
        OGGuidText := DelChr(Format(CreateGuid()), '=', '{}-');
        OGSeriesCode := CopyStr('OG' + OGGuidText, 1, MaxStrLen(OGSeriesCode));
        exit(OGSeriesCode);
    end;

    local procedure OGAssertTrue(OGCondition: Boolean; OGMessage: Text)
    begin
        if not OGCondition then
            Error(OGMessage);
    end;

    local procedure OGAssertEqualInteger(OGExpected: Integer; OGActual: Integer; OGContext: Text)
    begin
        if OGExpected <> OGActual then
            Error('%1 Expected %2 but got %3.', OGContext, OGExpected, OGActual);
    end;
}
