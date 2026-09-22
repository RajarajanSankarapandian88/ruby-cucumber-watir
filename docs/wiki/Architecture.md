# Architecture

## Execution flow

`run-ai-trends.ps1` prepares the browser environment, clears Allure results
once for the entire run, and starts Cucumber with the `external` profile. The
Cucumber formatter writes raw results to `allure-results`; the report script
turns them into an HTML report using the project-local Allure CLI.

```text
PowerShell runner -> Cucumber -> Watir/Selenium -> Bing
                       |              |
                       v              v
                 Allure results   text/JSON artifacts
                       |
                       v
                  Allure report
```

## Boundaries

`SearchPage` owns browser navigation and result extraction. Step definitions
express business intent and write traceable artifacts. `env.rb` owns Cucumber
hooks, browser lifecycle, and Allure configuration.

The live scenario has `@external @ui` tags. Browser setup and teardown run
only for `@ui` scenarios, allowing future deterministic non-browser tests to
execute without a driver.

## Parallel execution

Allure cleanup occurs in the PowerShell runner rather than Cucumber hooks.
Workers append results to the same directory; do not reintroduce per-worker
cleanup when adding parallel execution.
