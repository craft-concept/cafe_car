# Security Policy

## Supported versions

CafeCar is pre-1.0 and under active development. Security fixes are applied to the
latest released minor line. Upgrade to the latest patch release before reporting a
problem that may already be fixed.

| Version | Supported          |
| ------- | ------------------ |
| 0.3.x   | :white_check_mark: |
| < 0.3   | :x:                |

## Reporting a vulnerability

Please report security vulnerabilities privately. **Do not open a public GitHub
issue for a security problem.**

Email **jeff@yak.sh** with:

- a description of the vulnerability and its impact,
- steps to reproduce (a proof of concept if you have one), and
- any suggested remediation.

You can expect an acknowledgement within a few business days. We'll work with you
to confirm the issue, prepare a fix, and coordinate disclosure once a patched
release is available. Please give us a reasonable window to address the issue
before any public disclosure.

## Security posture

CafeCar runs [Brakeman](https://brakemanscanner.org/), a static analysis security
scanner for Rails, as part of the CI check suite (`rake`) on every push. New code
is expected to keep the Brakeman gate green.
