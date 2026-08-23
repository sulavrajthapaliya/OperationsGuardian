codeunit 71016 "OG Approval Rules" implements "OG Rule Provider"
{
    procedure OGEvaluate(OGRuleSetup: Record "OG Rule Setup"; OGRunId: Guid; OGRunAt: DateTime)
    var
        OGApprovalEntry: Record "Approval Entry";
        OGExceptionEngine: Codeunit "OG Exception Engine";
        OGSourceNo: Code[50];
        OGCutoffDateTime: DateTime;
        OGDescription: Text[250];
        OGFingerprint: Text[250];
        OGRecommendation: Text[250];
        OGDetails: Text[2048];
    begin
        if OGRuleSetup."OG Code" <> 'APPROVAL-AGING' then
            exit;

        OGCutoffDateTime := CreateDateTime(Today() - OGRuleSetup."OG Threshold Days", 000000T);

        OGApprovalEntry.SetRange(Status, OGApprovalEntry.Status::Open);
        OGApprovalEntry.SetFilter("Date-Time Sent for Approval", '<>%1&<=%2', 0DT, OGCutoffDateTime);
        if not OGApprovalEntry.FindSet() then
            exit;

        repeat
            OGFingerprint := CopyStr(StrSubstNo(OGAppFingerprintFormatLbl, OGApprovalEntry."Entry No."), 1, MaxStrLen(OGFingerprint));
            OGSourceNo := CopyStr(OGApprovalEntry."Document No.", 1, MaxStrLen(OGSourceNo));
            if OGSourceNo = '' then
                OGSourceNo := CopyStr(Format(OGApprovalEntry."Entry No."), 1, MaxStrLen(OGSourceNo));

            OGDescription := CopyStr(StrSubstNo(OGAppDescriptionFormatLbl, OGSourceNo), 1, MaxStrLen(OGDescription));
            OGDetails := CopyStr(
                StrSubstNo(OGAppDetailsFormatLbl,
                    OGApprovalEntry."Approver ID",
                    OGApprovalEntry."Date-Time Sent for Approval",
                    OGApprovalEntry."Due Date",
                    OGApprovalEntry."Sender ID",
                    OGApprovalEntry."Approval Code"),
                1,
                MaxStrLen(OGDetails));
            OGRecommendation := CopyStr('Review the approval request and remind, delegate, approve, or reject it as appropriate.', 1, MaxStrLen(OGRecommendation));

            OGExceptionEngine.OGUpsertException(
                OGRuleSetup,
                OGFingerprint,
                Database::"Approval Entry",
                OGApprovalEntry.SystemId,
                OGSourceNo,
                OGDescription,
                OGDetails,
                OGRecommendation,
                OGRunId,
                OGRunAt);
        until OGApprovalEntry.Next() = 0;
    end;

    var
        OGAppDescriptionFormatLbl: Label 'Approval request %1 is waiting too long'; // %1 = source document number
        OGAppDetailsFormatLbl: Label 'Approver %1; sent %2; due date %3; sender %4; approval code %5.'; // %1 = approver ID, %2 = sent date/time, %3 = due date, %4 = sender ID, %5 = approval code
        OGAppFingerprintFormatLbl: Label 'APPROVAL|%1'; // %1 = approval entry number
}
