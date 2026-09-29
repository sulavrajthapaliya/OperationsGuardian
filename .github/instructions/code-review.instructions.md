# Code Review

Review the selected code and list all issues found. Do not skip minor issues — report everything you find.

## Focus Areas

### Logic & Bugs

- Identify any logical errors, incorrect conditions, or edge cases that are not handled.
- Flag any code that could produce unexpected behavior or wrong results.
- Look for off-by-one errors, null/empty value handling, and incorrect assumptions.

### Readability & Naming

- Flag unclear, misleading, or abbreviated variable and function names.
- Identify functions or blocks that are too long or doing more than one thing.
- Note any missing or unclear comments where the intent is not obvious from the code.

### Performance

- Identify any unnecessary loops, repeated calculations, or redundant database/API calls.
- Flag inefficient data structures or operations that could be simplified.
- Note any operations inside loops that could be moved outside.

## Output Format

- List all issues found, grouped by the three focus areas above.
- For each issue, state: what the problem is, where it is, and why it matters.
- Do not suggest fixes unless explicitly asked — focus on identifying issues clearly.

## Important Notes
- Make sure the launch.json configuration parameter is blank as it should be configured at workspace level.
- The pull request should contain Work Item in the description. Example: **AB#12345**
- Change log should be updated with the changes made in the pull request.
