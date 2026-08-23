## [1.2.0.0] - 2026-08-23
- Added transactional per-rule execution using `Codeunit.Run` so failed rule writes roll back and later rules continue.
- Added persistent `OG Last Error` handling for failed rules.
- Added publisher-scope custom telemetry events for scan/rule outcomes without emitting customer error text.
- Added `NO-SERIES-EXHAUSTION` as the eighth default rule.
- Added a separate automated AL test extension covering core engine and Number Series scenarios.

## [1.1.0.0] - 2026-08-23
- Added Business Manager Role Center cues for open, critical, warning, and ignored exceptions.
- Added actionable critical-exception web client notification.
- Added `JOB-QUEUE-FAILED` default rule and system rule provider.
- Added `APPROVAL-AGING` default rule and approval rule provider.
- Default rule seeding now creates seven rules and ensures the cue singleton record exists.
- Updated permission sets for approval, cue, and notification components.


## [1.0.1.0] - 2026-08-23
- Confirmed automatic creation of the 5 default rules during company install.
- Added upgrade codeunit to restore missing default rules during app upgrade.
- Documented manual fallback action: **Add Missing Default Rules**.

# Changelog

## 1.0.0.0

- Added exception engine with automatic reopen/resolve lifecycle.
- Added extensible AL rule-provider interface and provider enum.
- Added five standard operational rules across sales, purchasing, inventory, warehouse, and manufacturing.
- Added exception inbox with source navigation, ignore, reopen, and manual scan actions.
- Added default-rule installation logic and user/admin permission sets.
- Added Job Queue-compatible scanner codeunit.
