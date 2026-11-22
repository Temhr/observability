# Changelog

## 0.3.0
### Breaking
- Removed the 0.2 aliases `loki-nixlab.{enableAlloy,alloyPort,alloyPackage}` and `loki-nixlab.maintenance.*`.
- Removed `systm--ports-*` modules; ports are option defaults (values unchanged).
- A standalone Loki (without the stack) no longer gets the 2-year `{job="maintenance-log"}` retention by default; the stack sets it via `retentionStreams`.
- Repository layout flattened (`modules/nixos/<service>/`); not public API.
### Deprecated (removed in 0.4.0)
- All `-nixlab` option names and module names (see ADR-010 and docs/architecture/public-api.md).
### Added
- Product-scoped names (ADR-010), `default` module, stable module keys, hermetic `mon-*` packages.
- Checks: `port-defaults`, `loki-config`, `alloy-config`, `loki-runbook-coverage`, `golden-domain-effects`, `double-import`, `options-doc-fresh`, `docs-links`, compat checks; `vm-smoke` package.
- Options: `services.observability-loki.retentionStreams`, `services.observability-maintenance-log.lokiJob`, `services.observability.integrations.nvidia.enable`.

## 0.2.1
### Fixed
- extraUsers on alloy-nixlab and prometheus-nixlab failed evaluation (referenced an undeclared group option).

## 0.2.0
### Breaking
See the table in docs/architecture/public-api.md.
### Added
- `no-nixlab-coupling` check, `external` and `minimal` harness hosts, `examples/minimal`.
- Options: `probes.icmpTargets`, `notifications.ntfyAuth.environmentFile`, `prometheus-nixlab.runbookBaseUrl`.

## 0.1.0
Initial extraction from nixlab.
