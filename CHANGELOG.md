# Changelog

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
