# Watir Cucumber Allure Framework

Ruby browser automation framework using Cucumber, Watir, Selenium WebDriver, and Allure Report 3. The included scenario searches Bing for current AI trends in test automation, validates that results are returned, and saves titles and direct links as both text and JSON artifacts.

## Versions

- Ruby 4.0.7
- Cucumber 11.1.1
- Watir 7.3.0
- Selenium WebDriver 4.49.0
- allure-cucumber 2.29.1
- Allure Report 3.18.0

The `win32ole` 1.9.3 gem is also pinned because Ruby 4 moved it out of the default gems while Cucumber's Windows platform detection still requires it.

## Project structure

```text
features/
  ai_trends.feature
  pages/search_page.rb
  step_definitions/ai_trends_steps.rb
  support/env.rb
scripts/
  setup.ps1
  run-ai-trends.ps1
  open-allure-report.ps1
```

## Run

From PowerShell in this directory:

```powershell
.\scripts\setup.ps1
.\scripts\run-ai-trends.ps1
.\scripts\open-allure-report.ps1
```

The test runs headlessly in Chrome by default. To watch the browser or use Edge:

```powershell
.\scripts\run-ai-trends.ps1 -Headless $false
.\scripts\run-ai-trends.ps1 -Browser edge -Headless $false
```

Outputs:

- `artifacts/ai_trends.txt` and `artifacts/ai_trends.json`: captured search results
- `allure-results/`: raw Allure results from Cucumber
- `allure-report/`: generated interactive Allure report

To generate the report without opening a browser:

```powershell
.\scripts\open-allure-report.ps1 -GenerateOnly
```

## Configuration

The following environment variables can be used directly when invoking Cucumber:

- `BROWSER`: `chrome` or `edge`
- `HEADLESS`: `true` or `false`
- `TEST_ENV`: environment name shown in Allure

On Windows, `setup.ps1` downloads the official Chrome-for-Testing driver matching the installed Chrome build and configures Watir to use it. This avoids proxy-related Selenium Manager lookups. Edge continues to use Selenium Manager.
