# Architecture

## Execution flow

`run-cucumber.ps1` clears Allure results once for the entire run and starts
Cucumber with either the `allure` or `external` profile. `run-ai-trends.ps1`
prepares the browser environment and delegates to that runner with the
`external` profile. The Cucumber formatter writes raw results to
`allure-results`; the report script turns them into an HTML report using the
project-local Allure CLI.

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

`run-cucumber.ps1` performs Allure cleanup before setting
`ALLURE_RESULTS_PREPARED=true`, so workers append to the same directory. Direct
serial Cucumber execution retains formatter cleanup to avoid stale reports; use
the runner for parallel execution and do not reintroduce per-worker cleanup.
