# Running the suite

## Prerequisites

- Windows with Ruby 4.0.7 at `C:\Ruby40-x64`
- Google Chrome for the live AI-trends scenario
- Node.js and npm

Run setup once from the repository root:

```powershell
.\scripts\setup.ps1
```

Run the explicit live integration scenario:

```powershell
.\scripts\run-ai-trends.ps1
```

Run a normal Allure-profile suite through the same run-level cleanup boundary:

```powershell
.\scripts\run-cucumber.ps1 -Profile allure
```

Use `-Headless $false` to watch Chrome, or `-Browser edge` to use Edge.

Generate the report without opening it:

```powershell
.\scripts\open-allure-report.ps1 -GenerateOnly
```

## Profiles

`default` and `allure` exclude `@external` tests. `external` is the only
profile that includes live search tests. This keeps ordinary CI runs isolated
from search-engine changes and network controls. Invoke Allure profiles through
`run-cucumber.ps1`, which removes stale results once before Cucumber begins.

## Outputs

- `artifacts/ai_trends.txt`: readable result capture
- `artifacts/ai_trends.json`: query, source, UTC capture time, and results
- `allure-results`: raw execution results
- `allure-report`: generated HTML report
