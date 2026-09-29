codeunit 71101 "OG Core Tests"
{
    RequiredTestIsolation = Function;
    Subtype = Test;

    [Test]
    procedure OGDefaultsCreateFifteenRules()
    var
        OGRuleSetup: Record "RuleSetup_OG_SRT";
        OGRuleSetupMgt: Codeunit "RuleSetupMgt_OG_SRT";
    begin
        OGRuleSetup.DeleteAll();

        OGRuleSetupMgt.OGEnsureDefaults();

        OGAssertEqualInteger(15, OGRuleSetup.Count(), 'Default rule count');
        OGAssertTrue(OGRuleSetup.Get('NO-SERIES-EXHAUSTION'), 'NO-SERIES-EXHAUSTION should be created.');
        OGAssertTrue(OGRuleSetup.Get('SALES-SETUP-INCOMPLETE'), 'SALES-SETUP-INCOMPLETE should be created.');
    end;

    [Test]
    procedure OGEnsureDefaultsPreservesExistingConfiguration()
    var
        OGRuleSetup: Record "RuleSetup_OG_SRT";
        OGRuleSetupMgt: Codeunit "RuleSetupMgt_OG_SRT";
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
        OGException: Record "Exception_OG_SRT";
        OGRuleSetup: Record "RuleSetup_OG_SRT";
        OGExceptionEngine: Codeunit "ExceptionEngine_OG_SRT";
        OGRunAt: DateTime;
        OGEmptyGuid: Guid;
        OGRunId: Guid;
    begin
        OGRuleSetup.DeleteAll();
        OGException.DeleteAll();
        OGInsertTestRule(OGRuleSetup, 'OGTEST-UPSERT', "RuleProvider_OG_SRT"::"OG None");

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
        OGException: Record "Exception_OG_SRT";
        OGRuleSetup: Record "RuleSetup_OG_SRT";
        OGExceptionEngine: Codeunit "ExceptionEngine_OG_SRT";
    begin
        OGRuleSetup.DeleteAll();
        OGException.DeleteAll();

        OGInsertTestRule(OGRuleSetup, 'A-FAIL', "RuleProvider_OG_SRT"::"OG Test Failure");
        OGInsertTestRule(OGRuleSetup, 'Z-SUCCESS', "RuleProvider_OG_SRT"::"OG None");

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
        OGException: Record "Exception_OG_SRT";
        OGRuleSetup: Record "RuleSetup_OG_SRT";
        OGExceptionEngine: Codeunit "ExceptionEngine_OG_SRT";
        OGEmptyGuid: Guid;
        OGOldRunId: Guid;
    begin
        OGRuleSetup.DeleteAll();
        OGException.DeleteAll();
        OGInsertTestRule(OGRuleSetup, 'OGTEST-RESOLVE', "RuleProvider_OG_SRT"::"OG None");

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
        OGException: Record "Exception_OG_SRT";
        OGNoSeries: Record "No. Series";
        OGNoSeriesLine: Record "No. Series Line";
        OGRuleSetup: Record "RuleSetup_OG_SRT";
        OGExceptionEngine: Codeunit "ExceptionEngine_OG_SRT";
        OGSeriesCode: Code[20];
    begin
        OGRuleSetup.DeleteAll();
        OGException.DeleteAll();
        OGInsertTestRule(OGRuleSetup, 'NO-SERIES-EXHAUSTION', "RuleProvider_OG_SRT"::"OG System");

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

    [Test]
    procedure OGMissingSalesSetupFieldCreatesActionableException()
    var
        OGException: Record "Exception_OG_SRT";
        OGRuleSetup: Record "RuleSetup_OG_SRT";
        OGSalesSetup: Record "Sales & Receivables Setup";
        OGExceptionEngine: Codeunit "ExceptionEngine_OG_SRT";
    begin
        OGRuleSetup.DeleteAll();
        OGException.DeleteAll();
        OGInsertTestRule(OGRuleSetup, 'SALES-SETUP-INCOMPLETE', "RuleProvider_OG_SRT"::"OG Setup");

        if not OGSalesSetup.Get() then begin
            OGSalesSetup.Init();
            OGSalesSetup.Insert();
        end;
        OGSalesSetup."Posted Invoice Nos." := '';
        OGSalesSetup.Modify();

        OGExceptionEngine.OGRunAll();

        OGException.SetRange("OG Rule Code", 'SALES-SETUP-INCOMPLETE');
        OGException.SetRange("OG Fingerprint", 'SETUP|SALES');
        OGAssertEqualInteger(1, OGException.Count(), 'Missing sales setup fields should create one aggregated exception.');
        OGException.FindFirst();
        OGAssertTrue(StrPos(OGException."OG Details", OGSalesSetup.FieldCaption("Posted Invoice Nos.")) > 0, 'Exception details should identify the missing setup field.');
        OGAssertTrue(not IsNullGuid(OGException."OG Source SystemId"), 'Setup exception should link to the setup record.');
    end;

    [Test]
    procedure OGMissingGeneralPostingAccountCreatesCombinationException()
    var
        OGException: Record "Exception_OG_SRT";
        OGGeneralPostingSetup: Record "General Posting Setup";
        OGRuleSetup: Record "RuleSetup_OG_SRT";
        OGExceptionEngine: Codeunit "ExceptionEngine_OG_SRT";
        OGFingerprint: Text[250];
    begin
        OGRuleSetup.DeleteAll();
        OGException.DeleteAll();
        OGInsertTestRule(OGRuleSetup, 'GEN-POSTING-SETUP-INCOMPLETE', "RuleProvider_OG_SRT"::"OG Setup");

        if not OGGeneralPostingSetup.FindFirst() then begin
            OGGeneralPostingSetup.Init();
            OGGeneralPostingSetup.Insert();
        end;
        OGGeneralPostingSetup."Sales Account" := '';
        OGGeneralPostingSetup.Modify();

        OGExceptionEngine.OGRunAll();

        OGFingerprint := CopyStr(StrSubstNo('SETUP|GEN-POSTING|%1|%2', OGGeneralPostingSetup."Gen. Bus. Posting Group", OGGeneralPostingSetup."Gen. Prod. Posting Group"), 1, MaxStrLen(OGFingerprint));
        OGException.SetRange("OG Rule Code", 'GEN-POSTING-SETUP-INCOMPLETE');
        OGException.SetRange("OG Fingerprint", OGFingerprint);
        OGAssertEqualInteger(1, OGException.Count(), 'Missing general posting account should create one exception for the combination.');
        OGException.FindFirst();
        OGAssertTrue(StrPos(OGException."OG Details", OGGeneralPostingSetup.FieldCaption("Sales Account")) > 0, 'Exception details should identify the missing general posting account.');
        OGAssertTrue(not IsNullGuid(OGException."OG Source SystemId"), 'General posting exception should link to the setup combination.');
    end;

    [Test]
    procedure OGMissingInventoryPostingAccountCreatesCombinationException()
    var
        OGException: Record "Exception_OG_SRT";
        OGInventoryPostingSetup: Record "Inventory Posting Setup";
        OGRuleSetup: Record "RuleSetup_OG_SRT";
        OGExceptionEngine: Codeunit "ExceptionEngine_OG_SRT";
        OGFingerprint: Text[250];
    begin
        OGRuleSetup.DeleteAll();
        OGException.DeleteAll();
        OGInsertTestRule(OGRuleSetup, 'INVT-POSTING-SETUP-INCOMPLETE', "RuleProvider_OG_SRT"::"OG Setup");

        if not OGInventoryPostingSetup.FindFirst() then begin
            OGInventoryPostingSetup.Init();
            OGInventoryPostingSetup.Insert();
        end;
        OGInventoryPostingSetup."Inventory Account" := '';
        OGInventoryPostingSetup.Modify();

        OGExceptionEngine.OGRunAll();

        OGFingerprint := CopyStr(StrSubstNo('SETUP|INVT-POSTING|%1|%2', OGInventoryPostingSetup."Location Code", OGInventoryPostingSetup."Invt. Posting Group Code"), 1, MaxStrLen(OGFingerprint));
        OGException.SetRange("OG Rule Code", 'INVT-POSTING-SETUP-INCOMPLETE');
        OGException.SetRange("OG Fingerprint", OGFingerprint);
        OGAssertEqualInteger(1, OGException.Count(), 'Missing inventory posting account should create one exception for the combination.');
        OGException.FindFirst();
        OGAssertTrue(StrPos(OGException."OG Details", OGInventoryPostingSetup.FieldCaption("Inventory Account")) > 0, 'Exception details should identify the missing inventory posting account.');
        OGAssertTrue(not IsNullGuid(OGException."OG Source SystemId"), 'Inventory posting exception should link to the setup combination.');
    end;

    local procedure OGInsertTestRule(var OGRuleSetup: Record "RuleSetup_OG_SRT"; OGCode: Code[50]; OGProvider: Enum "RuleProvider_OG_SRT")
    begin
        OGRuleSetup.Init();
        OGRuleSetup."OG Code" := OGCode;
        OGRuleSetup."OG Description" := CopyStr('Automated test rule ' + OGCode, 1, MaxStrLen(OGRuleSetup."OG Description"));
        OGRuleSetup."OG Area" := "ExceptionArea_OG_SRT"::"OG System";
        OGRuleSetup."OG Severity" := "ExceptionSeverity_OG_SRT"::"OG Warning";
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
