# Open Issues

Resolved work lives in `RESOLVED_ISSUES.md`.

## Current Status

- Blueprint / contract parser fixes below are merged locally; rerun the macOS test scripts after `git pull` on the Mac to confirm the full baseline.
- Ongoing language enhancement work continues as normal feature development when the harness is green.

## Contract / follows / blueprint methods

- **Resolved in tree** (see `RESOLVED_ISSUES.md` §41): blueprint bodies now set `current_blueprint_parse` on first registration (not only after preparse lookup), and refining preparse method stubs no longer skips storing body anchors, parameters, and return metadata (those omissions broke contract checks and `obj.method()` dispatch).
- **Regression:** `tests/test_contract_follows.sn` should compile and run after rebuild.