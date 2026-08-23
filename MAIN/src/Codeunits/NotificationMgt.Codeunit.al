codeunit 71005 "OG Notification Mgt."
{
    procedure OGNotifyCriticalExceptions()
    var
        OGException: Record "OG Exception";
        OGCriticalNotification: Notification;
        OGCriticalCount: Integer;
    begin
        if not GuiAllowed() then
            exit;

        OGException.SetRange("OG Status", OGException."OG Status"::"OG Open");
        OGException.SetRange("OG Severity", OGException."OG Severity"::"OG Critical");
        OGCriticalCount := OGException.Count();
        if OGCriticalCount = 0 then
            exit;

        OGCriticalNotification.Message := StrSubstNo(OGCriticalExceptionsMsg, OGCriticalCount);
        OGCriticalNotification.Scope := NotificationScope::LocalScope;
        OGCriticalNotification.AddAction(OGViewCriticalActionLbl, Codeunit::"OG Notification Mgt.", 'OGOpenCriticalExceptions', OGViewCriticalActionToolTipLbl);
        OGCriticalNotification.Send();
    end;

    procedure OGOpenCriticalExceptions(OGNotification: Notification)
    var
        OGException: Record "OG Exception";
    begin
        OGException.SetRange("OG Status", OGException."OG Status"::"OG Open");
        OGException.SetRange("OG Severity", OGException."OG Severity"::"OG Critical");
        Page.Run(Page::"OG Exception Inbox", OGException);
    end;

    var
        OGCriticalExceptionsMsg: Label 'Operations Guardian found %1 open critical exception(s).'; // %1 = count of open critical exceptions
        OGViewCriticalActionLbl: Label 'View Critical Exceptions';
        OGViewCriticalActionToolTipLbl: Label 'Open the Operations Guardian inbox filtered to critical exceptions.';
}
