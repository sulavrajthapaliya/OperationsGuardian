page 71000 "OG Exception Inbox"
{
    PageType = List;
    SourceTable = "OG Exception";
    Caption = 'Operations Guardian';
    ApplicationArea = All;
    UsageCategory = Lists;
    Editable = false;
    SourceTableView = sorting("OG Status", "OG Severity", "OG Last Detected At") order(descending);

    layout
    {
        area(Content)
        {
            repeater(OGExceptions)
            {
                field(OGSeverity; Rec."OG Severity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the severity of the exception.';
                }
                field(OGStatus; Rec."OG Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the exception is open, ignored, or resolved.';
                }
                field(OGArea; Rec."OG Area")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the functional area where the exception was detected.';
                }
                field(OGDescription; Rec."OG Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Describes the detected exception.';
                }
                field(OGSourceNo; Rec."OG Source No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the source document or record number.';
                }
                field(OGRuleCode; Rec."OG Rule Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the rule that detected the exception.';
                }
                field(OGDetectedAt; Rec."OG Detected At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the exception was first detected.';
                }
                field(OGLastDetectedAt; Rec."OG Last Detected At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when the exception was most recently detected.';
                }
                field(OGIgnoredUntil; Rec."OG Ignored Until")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when an ignored exception becomes active again.';
                }
                field(OGSeenCount; Rec."OG Seen Count")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies how many scans have detected this exception.';
                }
            }
        }

        area(FactBoxes)
        {
            part(OGExceptionFactbox; "OG Exception FactBox")
            {
                ApplicationArea = All;
                SubPageLink = "OG Entry No." = field("OG Entry No.");
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(OGRunScan)
            {
                Caption = 'Run Scan';
                ApplicationArea = All;
                Image = Refresh;
                ToolTip = 'Runs all enabled Operations Guardian rules now.';

                trigger OnAction()
                var
                    OGExceptionEngine: Codeunit "OG Exception Engine";
                    OGNotificationMgt: Codeunit "OG Notification Mgt.";
                begin
                    OGExceptionEngine.OGRunAll();
                    OGNotificationMgt.OGNotifyCriticalExceptions();
                    CurrPage.Update(false);
                end;
            }
            action(OGOpenSource)
            {
                Caption = 'Open Source';
                ApplicationArea = All;
                Image = Navigate;
                ToolTip = 'Opens the Business Central record that caused the exception.';

                trigger OnAction()
                var
                    OGExceptionEngine: Codeunit "OG Exception Engine";
                begin
                    OGExceptionEngine.OGOpenSource(Rec);
                end;
            }
            action(OGIgnoreOneDay)
            {
                Caption = 'Ignore for 1 Day';
                ApplicationArea = All;
                Image = Pause;
                ToolTip = 'Temporarily ignores the selected exception for one day.';

                trigger OnAction()
                var
                    OGExceptionEngine: Codeunit "OG Exception Engine";
                begin
                    OGExceptionEngine.OGIgnoreForDays(Rec, 1);
                    CurrPage.Update(false);
                end;
            }
            action(OGIgnoreSevenDays)
            {
                Caption = 'Ignore for 7 Days';
                ApplicationArea = All;
                Image = Pause;
                ToolTip = 'Temporarily ignores the selected exception for seven days.';

                trigger OnAction()
                var
                    OGExceptionEngine: Codeunit "OG Exception Engine";
                begin
                    OGExceptionEngine.OGIgnoreForDays(Rec, 7);
                    CurrPage.Update(false);
                end;
            }
            action(OGReopen)
            {
                Caption = 'Reopen';
                ApplicationArea = All;
                ToolTip = 'Reopens an ignored or resolved exception.';

                trigger OnAction()
                var
                    OGExceptionEngine: Codeunit "OG Exception Engine";
                begin
                    OGExceptionEngine.OGReopen(Rec);
                    CurrPage.Update(false);
                end;
            }
            action(OGRuleSetup)
            {
                Caption = 'Rules';
                ApplicationArea = All;
                Image = Setup;
                RunObject = page "OG Rule Setup";
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
