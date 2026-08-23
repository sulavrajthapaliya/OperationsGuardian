codeunit 71016 "OG Approval Rules" implements "OG Rule Provider"
{
    procedure OGEvaluate(OGRuleSetup: Record "OG Rule Setup"; OGRunId: Guid; OGRunAt: DateTime)
    var
        OGApprovalEntry: Record "Approval Entry";
        OGExceptionEngine: Codeunit "OG Exception Engine";
        OGCutoffDateTime: DateTime;
        OGFingerprint: Text[250];
        OGDescription: Text[250];
        OGDetails: Text[2048];
        OGRecommendation: Text[250];
        OGSourceNo: Code[50];
    begin
        if OGRuleSetup."OG Code" <> 'APPROVAL-AGING' then
            exit;

        OGCutoffDateTime := CreateDateTime(Today() - OGRuleSetup."OG Threshold Days", 000000T);

        OGApprovalEntry.SetRange(Status, OGApprovalEntry.Status::Open);
        OGApprovalEntry.SetFilter("Date-Time Sent for Approval", '<>%1&<=%2', 0DT, OGCutoffDateTime);
        if not OGApprovalEntry.FindSet() then
            exit;

        repeat
            OGFingerprint := CopyStr(StrSubstNo('APPROVAL|%1', OGApprovalEntry."Entry No."), 1, MaxStrLen(OGFingerprint));
            OGSourceNo := CopyStr(OGApprovalEntry."Document No.", 1, MaxStrLen(OGSourceNo));
            if OGSourceNo = '' then
                OGSourceNo := CopyStr(Format(OGApprovalEntry."Entry No."), 1, MaxStrLen(OGSourceNo));

            OGDescription := CopyStr(StrSubstNo('Approval request %1 is waiting too long', OGSourceNo), 1, MaxStrLen(OGDescription));
            OGDetails := CopyStr(
                StrSubstNo('Approver %1; sent %2; due date %3; sender %4; approval code %5.',
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
}
