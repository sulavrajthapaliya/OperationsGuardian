codeunit 71005 "NotificationMgt_OG_SRT"
{
    procedure OGNotifyCriticalExceptions()
    var
        OGException: Record "Exception_OG_SRT";
        OGCriticalNotification: Notification;
        OGCriticalCount: Integer;
    begin
        if not GuiAllowed() then
            exit;

        OGException.SetRange("Status", OGException."Status"::"Open");
        OGException.SetRange("Severity", OGException."Severity"::"Critical");
        OGCriticalCount := OGException.Count();
        if OGCriticalCount = 0 then
            exit;

        OGCriticalNotification.Message := StrSubstNo(OGCriticalExceptionsMsg, OGCriticalCount);
        OGCriticalNotification.Scope := NotificationScope::LocalScope;
        OGCriticalNotification.AddAction(OGViewCriticalActionLbl, Codeunit::"NotificationMgt_OG_SRT", 'OGOpenCriticalExceptions', OGViewCriticalActionToolTipLbl);
        OGCriticalNotification.Send();
    end;

    procedure OGOpenCriticalExceptions(OGNotification: Notification)
    var
        OGException: Record "Exception_OG_SRT";
    begin
        OGException.SetRange("Status", OGException."Status"::"Open");
        OGException.SetRange("Severity", OGException."Severity"::"Critical");
        Page.Run(Page::"ExceptionInbox_OG_SRT", OGException);
    end;

    var
        OGCriticalExceptionsMsg: Label 'Operations Guardian found %1 open critical exception(s).', Comment = '%1 = count of open critical exceptions';
        OGViewCriticalActionLbl: Label 'View Critical Exceptions';
        OGViewCriticalActionToolTipLbl: Label 'Open the Operations Guardian inbox filtered to critical exceptions.';
}
