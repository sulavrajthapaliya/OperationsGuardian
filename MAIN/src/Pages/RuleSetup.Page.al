page 71002 "OG Rule Setup"
{
    ApplicationArea = All;
    Caption = 'Operations Guardian Rules';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "OG Rule Setup";
    UsageCategory = Administration;

    layout
    {
        area(Content)
        {
            repeater(OGRules)
            {
                field(OGCode; Rec."OG Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unique rule code.';
                }
                field(OGDescription; Rec."OG Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Describes what the rule detects.';
                }
                field(OGEnabled; Rec."OG Enabled")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the rule is evaluated during a scan.';
                }
                field(OGArea; Rec."OG Area")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the functional area for the rule.';
                }
                field(OGSeverity; Rec."OG Severity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the severity assigned to exceptions detected by the rule.';
                }
                field(OGProvider; Rec."OG Provider")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the AL provider that evaluates the rule.';
                }
                field(OGThresholdDays; Rec."OG Threshold Days")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of days used by rules that evaluate document age.';
                }
                field(OGLastRunAt; Rec."OG Last Run At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies when this rule last ran successfully.';
                }
                field(OGLastError; Rec."OG Last Error")
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
                    OGRuleSetupMgt: Codeunit "OG Rule Setup Mgt.";
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
                    OGExceptionEngine: Codeunit "OG Exception Engine";
                    OGNotificationMgt: Codeunit "OG Notification Mgt.";
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
                RunObject = page "OG Exception Inbox";
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
