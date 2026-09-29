page 71002 "RuleSetup_OG_SRT"
{
    ApplicationArea = All;
    Caption = 'Operations Guardian Rules';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "RuleSetup_OG_SRT";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            repeater(OGRules)
            {
                field(OGCode; Rec."Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unique rule code.';
                }
                field(OGDescription; Rec."Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Describes what the rule detects.';
                }
                field(OGEnabled; Rec."Enabled")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the rule is evaluated during a scan.';
                }
                field(OGArea; Rec."Area")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the functional area for the rule.';
                }
                field(OGSeverity; Rec."Severity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the severity assigned to exceptions detected by the rule.';
                }
                field(OGProvider; Rec."Provider")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the AL provider that evaluates the rule.';
                }
                field(OGThresholdDays; Rec."Threshold Days")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of days used by rules that evaluate document age.';
                }
                field(OGLastRunAt; Rec."Last Run At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when this rule last ran successfully.';
                }
                field(OGLastError; Rec."Last Error")
                {
                    ApplicationArea = All;
                    ToolTip = 'Shows the most recent rule evaluation error, if any.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(OGRestoreDefaults)
            {
                ApplicationArea = All;
                Caption = 'Add Missing Default Rules';
                Image = Insert;
                ToolTip = 'Adds any standard Operations Guardian rules that do not already exist.';

                trigger OnAction()
                var
                    OGRuleSetupMgt: Codeunit "RuleSetupMgt_OG_SRT";
                begin
                    OGRuleSetupMgt.OGEnsureDefaults();
                    CurrPage.Update(false);
                end;
            }
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
            action(OGOpenInbox)
            {
                ApplicationArea = All;
                Caption = 'Exception Inbox';
                Image = List;
                RunObject = page "ExceptionInbox_OG_SRT";
                ToolTip = 'Opens the Operations Guardian exception inbox.';
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
                actionref(OGOpenInboxPromoted; OGOpenInbox)
                {
                }
            }
        }
    }
}
