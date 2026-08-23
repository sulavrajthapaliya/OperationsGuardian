# Operations Guardian Tests

Automated AL test extension for Operations Guardian v1.2.0.

## Covered scenarios

1. Fifteen default rules are created.
2. Re-running default creation does not overwrite customer configuration.
3. Exception upsert remains unique by rule + fingerprint.
4. A failed provider rolls back partial exception writes and does not stop later rules.
5. A successful rule run resolves exceptions that are no longer detected.
6. A current No. Series line at its Warning No. creates a `NO-SERIES-EXHAUSTION` exception.
7. A missing Sales & Receivables Setup field creates one actionable, source-linked setup exception.
8. Missing General Posting Setup and Inventory Posting Setup accounts create source-linked exceptions for their exact posting-group combinations.

## Run on BC v28+

1. Publish **Operations Guardian** first.
2. Open this test project and run **AL: Download Symbols**.
3. Publish the test app to a sandbox.
4. Open VS Code **Test Explorer** and run codeunit **OG Core Tests**.
5. For runner-based CI/test execution, codeunit **OG Test Runner** uses `TestIsolation = Function`.

The test app is intended for sandbox/CI validation and is not part of the AppSource production package.
