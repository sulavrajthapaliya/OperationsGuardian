page 71003 "OG Role Center Cues"
{
    PageType = CardPart;
    SourceTable = "OG Cue";
    Caption = 'Operations Guardian';
    ApplicationArea = All;
    RefreshOnActivate = true;

    layout
    {
        area(Content)
        {
            cuegroup(OGExceptions)
            {
                Caption = 'Operations Guardian';

                field(OGCriticalExceptions; Rec."OG Critical Exceptions")
                {
                    ApplicationArea = All;
                    DrillDownPageId = "OG Exception Inbox";
                    ToolTip = 'Shows the number of open critical Operations Guardian exceptions.';
                }
                field(OGWarningExceptions; Rec."OG Warning Exceptions")
                {
                    ApplicationArea = All;
                    DrillDownPageId = "OG Exception Inbox";
                    ToolTip = 'Shows the number of open warning Operations Guardian exceptions.';
                }
                field(OGOpenExceptions; Rec."OG Open Exceptions")
                {
                    ApplicationArea = All;
                    DrillDownPageId = "OG Exception Inbox";
                    ToolTip = 'Shows the total number of open Operations Guardian exceptions.';
                }
                field(OGIgnoredExceptions; Rec."OG Ignored Exceptions")
                {
                    ApplicationArea = All;
                    DrillDownPageId = "OG Exception Inbox";
                    ToolTip = 'Shows the number of ignored Operations Guardian exceptions.';
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        OGRuleSetupMgt: Codeunit "OG Rule Setup Mgt.";
        OGNotificationMgt: Codeunit "OG Notification Mgt.";
    begin
        OGRuleSetupMgt.OGEnsureCueRecord();
        Rec.Get(1);
        OGNotificationMgt.OGNotifyCriticalExceptions();
    end;
}
