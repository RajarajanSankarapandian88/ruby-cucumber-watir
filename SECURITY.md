# Security policy

## Supported configuration

Only the dependency versions committed in `Gemfile.lock` and `package-lock.json`
are supported. Use `bundle install` and `npm ci --include=dev` rather than unconstrained
package installs.

## Reporting a vulnerability

Do not include exploit details or credentials in a public issue. Report a
suspected vulnerability privately to the repository owner and include affected
versions, reproduction steps, and impact.

## Runtime safeguards

- The live Bing scenario is tagged `@external` and excluded from default runs.
- Search result artifacts retain only HTTP(S) URLs and include query, source,
  and capture time for traceability.
- ChromeDriver is selected from Chrome for Testing metadata over HTTPS and its
  executable must carry a valid Google LLC code-signing signature, including
  when it is restored from a local cache.
- The Allure command is invoked from the locked local `node_modules` install;
  it is not downloaded at report-generation time.
- Corporate trust bundles created by `setup.ps1` are local, ignored by Git, and
  should never be committed.
