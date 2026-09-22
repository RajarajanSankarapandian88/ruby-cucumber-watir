# Troubleshooting

## Ruby or Bundler cannot reach a package registry

Run `setup.ps1`. It exports the Windows trusted roots into an ignored local PEM
bundle for the current setup process. Do not disable TLS verification.

## ChromeDriver cannot be installed

Confirm Chrome is installed in a standard Program Files location and that the
machine can reach Chrome for Testing. The script fails if the downloaded driver
does not have a valid Google LLC signature.

## Live search test fails

The test depends on Bing, network access, consent pages, and current search
markup. Re-run it only after checking the generated screenshot and Allure
attachments. Do not make it a mandatory deterministic CI test.

## Report command says Allure is missing

Run `setup.ps1` to install the exact locked Node dependencies. The report script
requires the local `node_modules/.bin/allure.cmd` and will not download a tool
at runtime.
