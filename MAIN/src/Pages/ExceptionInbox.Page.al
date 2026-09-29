page 71000 "ExceptionInbox_OG_SRT"
{
    ApplicationArea = All;
    Caption = 'Operations Guardian';
    Editable = false;
    PageType = List;
    SourceTable = "Exception_OG_SRT";
    SourceTableView = sorting("Status", "Severity", "Last Detected At") order(descending);
    UsageCategory = Lists;

    layout
    {
        area(Content)
        {
            repeater(OGExceptions)
            {
                field(OGSeverity; Rec."Severity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the severity of the exception.';
                }
                field(OGStatus; Rec."Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the exception is open, ignored, or resolved.';
                }
                field(OGArea; Rec."Area")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the functional area where the exception was detected.';
                }
                field(OGDescription; Rec."Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Describes the detected exception.';
                }
                field(OGSourceNo; Rec."Source No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the source document or record number.';
                }
                field(OGRuleCode; Rec."Rule Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the rule that detected the exception.';
                }
                field(OGDetectedAt; Rec."Detected At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the exception was first detected.';
                }
                field(OGLastDetectedAt; Rec."Last Detected At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the exception was most recently detected.';
                }
                field(OGIgnoredUntil; Rec."Ignored Until")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when an ignored exception becomes active again.';
                }
                field(OGSeenCount; Rec."Seen Count")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies how many scans have detected this exception.';
                }
            }
        }

        area(FactBoxes)
        {
            part(OGExceptionFactbox; "ExceptionFactBox_OG_SRT")
            {
                ApplicationArea = All;
                SubPageLink = "Entry No." = field("Entry No.");
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(OGRunScan)
            {
                ApplicationArea = All;
                Caption = 'Run Scan';
                Image = Refresh;
                ToolTip = 'Runs all enabled Operations Guardian rules now.';

                trigger OnAction()
                var
                    OGExceptionEngine: Codeunit "ExceptionEngine_OG_SRT";
                    OGNotificationMgt: Codeunit "NotificationMgt_OG_SRT";
                begin
                    OGExceptionEngine.OGRunAll();
                    OGNotificationMgt.OGNotifyCriticalExceptions();
                    CurrPage.Update(false);
                end;
            }
            action(OGOpenSource)
            {
                ApplicationArea = All;
                Caption = 'Open Source';
                Image = Navigate;
                ToolTip = 'Opens the Business Central record that caused the exception.';

                trigger OnAction()
                var
                    OGExceptionEngine: Codeunit "ExceptionEngine_OG_SRT";
                begin
                    OGExceptionEngine.OGOpenSource(Rec);
                end;
            }
            action(OGIgnoreOneDay)
            {
                ApplicationArea = All;
                Caption = 'Ignore for 1 Day';
                Image = Pause;
                ToolTip = 'Temporarily ignores the selected exception for one day.';

                trigger OnAction()
                var
                    OGExceptionEngine: Codeunit "ExceptionEngine_OG_SRT";
                begin
                    OGExceptionEngine.OGIgnoreForDays(Rec, 1);
                    CurrPage.Update(false);
                end;
            }
            action(OGIgnoreSevenDays)
            {
                ApplicationArea = All;
                Caption = 'Ignore for 7 Days';
                Image = Pause;
                ToolTip = 'Temporarily ignores the selected exception for seven days.';

                trigger OnAction()
                var
                    OGExceptionEngine: Codeunit "ExceptionEngine_OG_SRT";
                begin
                    OGExceptionEngine.OGIgnoreForDays(Rec, 7);
                    CurrPage.Update(false);
                end;
            }
            action(OGReopen)
            {
                ApplicationArea = All;
                Caption = 'Reopen';
                ToolTip = 'Reopens an ignored or resolved exception.';

                trigger OnAction()
                var
                    OGExceptionEngine: Codeunit "ExceptionEngine_OG_SRT";
                begin
                    OGExceptionEngine.OGReopen(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(OGRuleSetup)
            {
                ApplicationArea = All;
                Caption = 'Rules';
                Image = Setup;
                RunObject = page "RuleSetup_OG_SRT";
                ToolTip = 'Opens Operations Guardian rule setup.';
            }
        }
        area(Promoted)
        {
            group(OGProcess)
            {
                Caption = 'Process';
                actionref(OGRunScanPromoted; OGRunScan)
                {
                }
                actionref(OGOpenSourcePromoted; OGOpenSource)
                {
                }
            }
        }
    }
}
