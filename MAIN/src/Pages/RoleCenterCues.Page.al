page 71003 "OG Role Center Cues"
{
    ApplicationArea = All;
    Caption = 'Operations Guardian';
    PageType = CardPart;
    RefreshOnActivate = true;
    SourceTable = "OG Cue";

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
        OGNotificationMgt: Codeunit "OG Notification Mgt.";
        OGRuleSetupMgt: Codeunit "OG Rule Setup Mgt.";
    begin
        OGRuleSetupMgt.OGEnsureCueRecord();
        Rec.Get(1);
        OGNotificationMgt.OGNotifyCriticalExceptions();
    end;
}
