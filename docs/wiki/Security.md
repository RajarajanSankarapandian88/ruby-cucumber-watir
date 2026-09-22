# Security

The framework treats browsers, drivers, dependencies, and external search as
separate trust boundaries.

- Lock Ruby and Node dependencies. Run `bundle install` and `npm ci`; review
  lockfile changes in pull requests.
- The driver bootstrap accepts only the official Chrome for Testing HTTPS host
  and verifies the extracted executable's Google LLC signature.
- Do not commit `.certs`, browser drivers, test artifacts, or Allure reports.
- Keep live-search tests tagged `@external`; do not use them as the only CI
  quality gate.
- Result artifacts allow only HTTP(S) links and preserve query/source/time so
  their origin is auditable.

If a corporate TLS proxy is used, `setup.ps1` creates a local certificate bundle
from Windows trusted roots. Treat that bundle as sensitive local configuration.
