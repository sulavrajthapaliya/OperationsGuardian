page 71003 "RoleCenterCues_OG_SRT"
{
    ApplicationArea = All;
    Caption = 'Operations Guardian';
    PageType = CardPart;
    RefreshOnActivate = true;
    SourceTable = "Cue_OG_SRT";

    layout
    {
        area(Content)
        {
            cuegroup(OGExceptions)
            {
                Caption = 'Operations Guardian';

                field(OGCriticalExceptions; Rec."Critical Exceptions")
                {
                    ApplicationArea = All;
                    DrillDownPageId = "ExceptionInbox_OG_SRT";
                    ToolTip = 'Shows the number of open critical Operations Guardian exceptions.';
                }
                field(OGWarningExceptions; Rec."Warning Exceptions")
                {
                    ApplicationArea = All;
                    DrillDownPageId = "ExceptionInbox_OG_SRT";
                    ToolTip = 'Shows the number of open warning Operations Guardian exceptions.';
                }
                field(OGOpenExceptions; Rec."Open Exceptions")
                {
                    ApplicationArea = All;
                    DrillDownPageId = "ExceptionInbox_OG_SRT";
                    ToolTip = 'Shows the total number of open Operations Guardian exceptions.';
                }
                field(OGIgnoredExceptions; Rec."Ignored Exceptions")
                {
                    ApplicationArea = All;
                    DrillDownPageId = "ExceptionInbox_OG_SRT";
                    ToolTip = 'Shows the number of ignored Operations Guardian exceptions.';
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        OGNotificationMgt: Codeunit "NotificationMgt_OG_SRT";
        OGRuleSetupMgt: Codeunit "RuleSetupMgt_OG_SRT";
    begin
        OGRuleSetupMgt.OGEnsureCueRecord();
        Rec.Get(1);
        OGNotificationMgt.OGNotifyCriticalExceptions();
    end;
}
