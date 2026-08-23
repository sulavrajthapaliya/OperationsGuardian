# Operations Guardian for Microsoft Dynamics 365 Business Central

Operations Guardian is a proactive operational exception inbox for Business Central. Instead of waiting for users to discover stuck or risky transactions, it scans enabled rules and creates actionable exceptions in one place.

## Target

- Business Central 2026 release wave 1 (v28)
- AL runtime 17.0
- Current development object range: `71000..71099`
- Current affix: `OG`

> Before AppSource submission, replace the publisher URLs, publisher name, object range, and `OG` affix with values registered/assigned to your publisher.

## Included rules

| Rule code | Area | What it detects | Default threshold |
|---|---|---|---:|
| `SALES-OVERDUE` | Sales | Released sales order with outstanding quantity and an overdue shipment date | 7 days |
| `PO-RECEIVED-NOT-INVOICED` | Purchasing | Purchase order with received quantity still not invoiced | 3 days |
| `ITEM-BELOW-SAFETY-STOCK` | Inventory | Item inventory below its safety stock quantity | n/a |
| `WHSE-SHIPMENT-STUCK` | Warehouse | Warehouse shipment header that has remained open too long | 2 days |
| `PROD-COMP-SHORTAGE` | Manufacturing | Released production order component where remaining quantity exceeds current inventory at the component location | n/a |
| `JOB-QUEUE-FAILED` | System | Job Queue Entry currently in Error status | n/a |
| `APPROVAL-AGING` | Approvals | Open approval request older than the configured threshold | 2 days |
| `NO-SERIES-EXHAUSTION` | System | Current applicable No. Series line has reached its warning number, ending number, or is closed/exhausted | n/a |
| `COMPANY-INFO-INCOMPLETE` | Setup | Company Information is missing core identity/address fields | n/a |
| `GL-SETUP-INCOMPLETE` | Setup | General Ledger Setup is missing the local currency code | n/a |
| `SALES-SETUP-INCOMPLETE` | Setup | Sales & Receivables Setup is missing core customer/document number series | n/a |
| `PURCHASE-SETUP-INCOMPLETE` | Setup | Purchases & Payables Setup is missing core vendor/document number series | n/a |
| `INVENTORY-SETUP-INCOMPLETE` | Setup | Inventory Setup is missing core item/transfer number series | n/a |
| `GEN-POSTING-SETUP-INCOMPLETE` | Setup | A General Posting Setup combination is absent or missing core posting accounts | n/a |
| `INVT-POSTING-SETUP-INCOMPLETE` | Setup | An Inventory Posting Setup combination is absent or missing required inventory accounts | n/a |

## Architecture

```text
Rule Setup
   |
   v
OG Exception Engine
   |
   +--> OG Rule Provider interface
           |
           +--> Sales Rules
           +--> Purchase Rules
           +--> Inventory Rules
           +--> Warehouse Rules
           +--> Manufacturing Rules
           +--> System Rules
           +--> Approval Rules
           +--> Setup Rules
   |
   v
OG Exception table
   |
   +--> Exception Inbox
   +--> Role Center Cues
   +--> Critical Notification
   +--> Ignore / Reopen
   +--> Open Source Record
```

The provider enum implements the `OG Rule Provider` interface. New providers can be added later through an enum extension and an implementing codeunit without modifying the exception engine.

## Main objects

- Table `71000` **OG Exception**
- Table `71001` **OG Rule Setup**
- Table `71002` **OG Cue**
- Page `71000` **OG Exception Inbox**
- Page `71002` **OG Rule Setup**
- Page `71003` **OG Role Center Cues**
- Page Extension `71000` **OG Business Manager RC**
- Codeunit `71000` **OG Exception Engine**
- Codeunit `71003` **OG Scanner Job**
- Codeunit `71005` **OG Notification Mgt.**
- Codeunit `71006` **OG Telemetry**
- Codeunit `71007` **OG Rule Runner**
- Codeunit `71008` **OG Rule Error Writer**
- Codeunit `71015` **OG System Rules**
- Codeunit `71016` **OG Approval Rules**
- Codeunit `71017` **OG Setup Rules**
- Interface **OG Rule Provider**
- Permission sets **OG USER** and **OG ADMIN**

## Install and test

1. Open this folder in VS Code with the AL Language extension.
2. Update `app.json` connection/project values as required for your sandbox.
3. Run **AL: Download Symbols**.
4. Publish the extension to a Business Central v28 sandbox.
5. Assign yourself the `OG ADMIN` permission set.
6. Search for **Operations Guardian Rules**. Fifteen default rules are inserted automatically by the install codeunit.
7. Choose **Run Scan**.
8. Search for **Operations Guardian** to open the exception inbox.
9. Test **Open Source**, **Ignore for 1 Day**, **Ignore for 7 Days**, and **Reopen**.
10. Switch to the **Business Manager** role and verify the Operations Guardian cue group is visible.
11. Put a test Job Queue Entry into **Error** and confirm `JOB-QUEUE-FAILED` creates an exception.
12. Use an open approval older than the configured threshold and confirm `APPROVAL-AGING` creates an exception.
13. Create or identify a current No. Series line whose **Last No. Used** has reached **Warning No.** and confirm `NO-SERIES-EXHAUSTION` creates an exception.
14. Clear a monitored field such as **Posted Invoice Nos.** in **Sales & Receivables Setup**, run the scan, and confirm `SALES-SETUP-INCOMPLETE` identifies the missing field.
15. Restore the setup field, run the scan again, and confirm the setup exception resolves automatically.
16. When one or more open critical exceptions exist, verify the client notification contains **View Critical Exceptions**.

## Schedule with Job Queue

Create a Job Queue Entry for:

- Object Type to Run: **Codeunit**
- Object ID to Run: **71003**
- Object Name: **OG Scanner Job**
- Recurring Job: **Yes**
- Suggested interval for testing: **30 minutes**

For production, choose the interval based on transaction volume and rule cost. A 30–60 minute interval is a sensible starting point for the current rules.

## Exception lifecycle

- A rule creates a unique exception using `Rule Code + Fingerprint`.
- If the same issue appears again, the existing exception is updated instead of duplicated.
- If a previously resolved exception reappears, it is reopened.
- Ignored exceptions stay ignored until their ignore date/time expires.
- If a rule no longer detects an existing exception during a successful scan, the engine marks it **Resolved** automatically.

## Important MVP limitations

This is deliberately a V1 core, not yet a finished marketplace product.

1. **Production shortage** uses current item inventory filtered by component location. It does not yet calculate projected availability, reservations, expected receipts, variants, or date-sensitive supply.
2. **Safety stock** uses the Item card safety stock quantity and global item inventory. A later version should support Stockkeeping Units and location/variant-specific policy.
3. **Warehouse shipment stuck** currently uses the header creation timestamp. A later version should distinguish waiting-for-pick, partial pick, missing stock, and user/process blockage.
4. **Purchase received-not-invoiced** is quantity-based and intentionally simple. A later version can add amount thresholds and GRNI aging.
5. Rule execution is synchronous, but each enabled rule now runs in its own `Codeunit.Run` transaction boundary. A failed rule rolls back its partial writes, stores `Last Error`, emits failure telemetry, and does not stop later rules.
6. Number Series risk detection compares the current applicable line against its configured Warning/Ending number. Complex custom numbering implementations should be regression-tested.
7. No AI capability is included in V1. The intended V2 is an **Explain Exception** and **Recommended Action** layer.

## Recommended next build sequence

### V1.3 - Product hardening

- Retention policy for resolved exception history
- Assisted Setup wizard
- User-level notification preferences and suppression windows
- Rule execution history table with duration/count trend
- Performance tests for high-volume companies

### V1.4 - Better operational intelligence

- Projected availability instead of simple inventory comparison
- Warehouse pick/ship state diagnostics
- Sales credit/blocked-customer rule
- User-configurable snooze/ignore reason

### V2 - AI

- Explain why an exception happened
- Summarize related documents and supply/demand
- Recommend a safe next action
- Generate user-facing email/reminder drafts

### V3 - Agent actions

- Safe, permission-aware actions such as creating a replenishment suggestion, sending a reminder, or opening the exact corrective workflow
- Approval/confirmation gates before transactional changes

## AppSource checklist reminders

Before submission:

- Register and use your real AppSource affix.
- Replace the development object range with the range assigned to your publisher/app.
- Replace all `example.com` URLs in `app.json`.
- Add app logo and marketplace screenshots.
- Compile with CodeCop, UICop, and AppSourceCop enabled.
- Build against a supported minimum runtime and also test against the latest BC runtime.
- Add automated install, upgrade, permission, rule, and performance tests.
- Run the official technical validation checklist before submission.


## Default rule creation

- On **app install**, the codeunit **`OG Install`** runs `OnInstallAppPerCompany()` and automatically creates the 15 standard rules if they do not already exist.
- On **app upgrade**, the codeunit **`OG Upgrade`** runs `OnUpgradePerCompany()` and adds back any missing standard rules.
- On the **Operations Guardian Rules** page, the action **Add Missing Default Rules** can be used manually at any time.


## V1.2 and current additions

Operations Guardian now seeds **15 default rules** on install/upgrade:

1. `SALES-OVERDUE`
2. `PO-RECEIVED-NOT-INVOICED`
3. `ITEM-BELOW-SAFETY-STOCK`
4. `WHSE-SHIPMENT-STUCK`
5. `PROD-COMP-SHORTAGE`
6. `JOB-QUEUE-FAILED`
7. `APPROVAL-AGING`
8. `NO-SERIES-EXHAUSTION`
9. `COMPANY-INFO-INCOMPLETE`
10. `GL-SETUP-INCOMPLETE`
11. `SALES-SETUP-INCOMPLETE`
12. `PURCHASE-SETUP-INCOMPLETE`
13. `INVENTORY-SETUP-INCOMPLETE`
14. `GEN-POSTING-SETUP-INCOMPLETE`
15. `INVT-POSTING-SETUP-INCOMPLETE`

### Setup completeness monitoring

The setup provider follows the same rule-provider pipeline as every operational rule. Singleton setup rules create one exception per setup area, while posting setup rules create one exception per posting-group combination. Each exception lists all missing fields, links back to the setup record when it exists, and resolves automatically after a later successful scan finds the setup complete. Individual setup checks can be disabled from **Operations Guardian Rules** when a module or workflow is intentionally unused.

The General Posting Setup rule checks the core sales, purchase, COGS, inventory adjustment, and direct-cost accounts. The Inventory Posting Setup rule always checks **Inventory Account** and also checks **Inventory Account (Interim)** when **Expected Cost Posting to G/L** is enabled.

Additional V1.2 hardening:

- **Per-rule transactional isolation:** each rule runs through `OG Rule Runner` using the Boolean `Codeunit.Run` pattern. Failed rule writes roll back and later rules continue.
- **Rule error persistence:** failed rules retain their error in `OG Last Error` without marking the rule as successfully run.
- **Custom telemetry:** `OG0001` scan started, `OG0002` rule success, `OG0003` rule failure, and `OG0004` scan completed. Custom dimensions include run ID, rule code, provider, severity, area, duration, result, and detection counts. Error text is intentionally excluded from telemetry to avoid leaking customer content.
- **Number Series exhaustion monitoring:** evaluates the current applicable No. Series line and flags warning-number reached, ending-number reached, or closed/exhausted lines.
- **Automated test project:** the sibling `OperationsGuardian.Tests` project contains AL test codeunits for defaults, idempotency, upsert uniqueness, failed-rule rollback/continuation, auto-resolution, and Number Series detection.
- **Business Manager Role Center cues**, **critical notifications**, **Job Queue failure monitoring**, and **approval aging monitoring** from V1.1 remain included.

### Telemetry notes

The app emits publisher-scope custom telemetry through `Session.LogMessage`. Business data and full provider error text are not included in the custom dimensions. Configure the publisher Application Insights destination using the supported Business Central extension telemetry configuration for your deployment/AppSource pipeline.

### Automated tests

The production app and test app are separate AL projects:

```text
OperationsGuardian/
OperationsGuardian.Tests/
```

Publish `Operations Guardian` first, then publish `Operations Guardian Tests` to a BC v28+ sandbox. Use VS Code **Test Explorer** to run codeunit **OG Core Tests**, or use **OG Test Runner** for runner-based execution with function-level isolation. The test extension is for sandbox/CI use and should not be included in the production AppSource package.

> The Role Center extension currently targets the standard **Business Manager Role Center**. Additional standard Role Centers can be added with small page extensions if desired.
