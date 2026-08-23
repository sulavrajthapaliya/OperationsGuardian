codeunit 71015 "OG System Rules" implements "OG Rule Provider"
{
    procedure OGEvaluate(OGRuleSetup: Record "OG Rule Setup"; OGRunId: Guid; OGRunAt: DateTime)
    begin
        case OGRuleSetup."OG Code" of
            'JOB-QUEUE-FAILED':
                OGEvaluateJobQueueFailures(OGRuleSetup, OGRunId, OGRunAt);
            'NO-SERIES-EXHAUSTION':
                OGEvaluateNoSeriesExhaustion(OGRuleSetup, OGRunId, OGRunAt);
        end;
    end;

    local procedure OGEvaluateJobQueueFailures(OGRuleSetup: Record "OG Rule Setup"; OGRunId: Guid; OGRunAt: DateTime)
    var
        OGJobQueueEntry: Record "Job Queue Entry";
        OGExceptionEngine: Codeunit "OG Exception Engine";
        OGFingerprint: Text[250];
        OGDescription: Text[250];
        OGDetails: Text[2048];
        OGRecommendation: Text[250];
        OGSourceNo: Code[50];
    begin
        OGJobQueueEntry.SetRange(Status, OGJobQueueEntry.Status::Error);
        if not OGJobQueueEntry.FindSet() then
            exit;

        repeat
            OGFingerprint := CopyStr(StrSubstNo('JOBQUEUE|%1', OGJobQueueEntry.ID), 1, MaxStrLen(OGFingerprint));
            OGDescription := CopyStr(StrSubstNo('Job queue entry %1 is in Error', OGJobQueueEntry.Description), 1, MaxStrLen(OGDescription));
            OGDetails := CopyStr(
                StrSubstNo('Object %1 %2; attempts %3 of %4; error: %5',
                    OGJobQueueEntry."Object Type to Run",
                    OGJobQueueEntry."Object ID to Run",
                    OGJobQueueEntry."No. of Attempts to Run",
                    OGJobQueueEntry."Maximum No. of Attempts to Run",
                    OGJobQueueEntry."Error Message"),
                1,
                MaxStrLen(OGDetails));
            OGRecommendation := CopyStr('Review the error, correct the root cause, then restart the job queue entry.', 1, MaxStrLen(OGRecommendation));
            OGSourceNo := CopyStr(Format(OGJobQueueEntry."Entry No."), 1, MaxStrLen(OGSourceNo));

            OGExceptionEngine.OGUpsertException(
                OGRuleSetup,
                OGFingerprint,
                Database::"Job Queue Entry",
                OGJobQueueEntry.SystemId,
                OGSourceNo,
                OGDescription,
                OGDetails,
                OGRecommendation,
                OGRunId,
                OGRunAt);
        until OGJobQueueEntry.Next() = 0;
    end;

    local procedure OGEvaluateNoSeriesExhaustion(OGRuleSetup: Record "OG Rule Setup"; OGRunId: Guid; OGRunAt: DateTime)
    var
        OGNoSeries: Record "No. Series";
        OGNoSeriesLine: Record "No. Series Line";
        OGExceptionEngine: Codeunit "OG Exception Engine";
        OGNoSeriesImplementation: Interface "No. Series - Single";
        OGLastNoUsed: Code[20];
        OGFingerprint: Text[250];
        OGDescription: Text[250];
        OGDetails: Text[2048];
        OGRecommendation: Text[250];
    begin
        if not OGNoSeries.FindSet() then
            exit;

        repeat
            if OGGetCurrentNoSeriesLine(OGNoSeries.Code, OGNoSeriesLine) then begin
                Clear(OGNoSeriesImplementation);
                OGNoSeriesImplementation := OGNoSeriesLine.Implementation;
                OGLastNoUsed := OGNoSeriesImplementation.GetLastNoUsed(OGNoSeriesLine);

                if OGIsNoSeriesAtRisk(OGNoSeriesLine, OGLastNoUsed) then begin
                    OGFingerprint := CopyStr(StrSubstNo('NOSERIES|%1|%2', OGNoSeriesLine."Series Code", OGNoSeriesLine."Line No."), 1, MaxStrLen(OGFingerprint));
                    OGDescription := CopyStr(StrSubstNo('Number series %1 is near exhaustion', OGNoSeries.Code), 1, MaxStrLen(OGDescription));
                    OGDetails := CopyStr(
                        StrSubstNo('Description %1; last used %2; warning no. %3; ending no. %4; open %5; starting date %6.',
                            OGNoSeries.Description,
                            OGLastNoUsed,
                            OGNoSeriesLine."Warning No.",
                            OGNoSeriesLine."Ending No.",
                            OGNoSeriesLine.Open,
                            OGNoSeriesLine."Starting Date"),
                        1,
                        MaxStrLen(OGDetails));
                    OGRecommendation := CopyStr('Extend the current number series or create the next dated line before document numbering is blocked.', 1, MaxStrLen(OGRecommendation));

                    OGExceptionEngine.OGUpsertException(
                        OGRuleSetup,
                        OGFingerprint,
                        Database::"No. Series Line",
                        OGNoSeriesLine.SystemId,
                        OGNoSeries.Code,
                        OGDescription,
                        OGDetails,
                        OGRecommendation,
                        OGRunId,
                        OGRunAt);
                end;
            end;
        until OGNoSeries.Next() = 0;
    end;

    local procedure OGGetCurrentNoSeriesLine(OGSeriesCode: Code[20]; var OGCurrentNoSeriesLine: Record "No. Series Line"): Boolean
    var
        OGNoSeriesLine: Record "No. Series Line";
        OGBestStartingDate: Date;
        OGBestLineNo: Integer;
        OGFound: Boolean;
    begin
        Clear(OGCurrentNoSeriesLine);
        OGNoSeriesLine.SetRange("Series Code", OGSeriesCode);
        OGNoSeriesLine.SetFilter("Starting Date", '<=%1', WorkDate());

        if not OGNoSeriesLine.FindSet() then
            exit(false);

        repeat
            if (not OGFound) or
               (OGNoSeriesLine."Starting Date" > OGBestStartingDate) or
               ((OGNoSeriesLine."Starting Date" = OGBestStartingDate) and (OGNoSeriesLine."Line No." > OGBestLineNo))
            then begin
                OGCurrentNoSeriesLine := OGNoSeriesLine;
                OGBestStartingDate := OGNoSeriesLine."Starting Date";
                OGBestLineNo := OGNoSeriesLine."Line No.";
                OGFound := true;
            end;
        until OGNoSeriesLine.Next() = 0;

        exit(OGFound);
    end;

    local procedure OGIsNoSeriesAtRisk(OGNoSeriesLine: Record "No. Series Line"; OGLastNoUsed: Code[20]): Boolean
    begin
        if not OGNoSeriesLine.Open then
            exit(true);

        if (OGNoSeriesLine."Warning No." <> '') and
           (OGLastNoUsed <> '') and
           (OGLastNoUsed >= OGNoSeriesLine."Warning No.")
        then
            exit(true);

        if (OGNoSeriesLine."Ending No." <> '') and
           (OGLastNoUsed <> '') and
           (OGLastNoUsed >= OGNoSeriesLine."Ending No.")
        then
            exit(true);

        exit(false);
    end;
}
