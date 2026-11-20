# ADR-010: Final module and option names

- **Status:** Accepted (<date>)
- **Supersedes:** ADR-003 decisions 4 and 5 (decisions 1–3 stand). Update ADR-003's status line to "Accepted; decisions 4–5 superseded by ADR-010".
- **Related:** ADR-003, ADR-005

## Context
ADR-003 deferred the final names. The `-nixlab` suffix is misleading for outside consumers, and consumers may merge several flakes' `nixosModules`, so generic names risk collisions.

## Decision
1. Category prefixes stay: `servc--` (single service), `systm--` (supporting capability), `stack--` (aggregator), `nsops--` (optional sops wiring).
2. Names are product-scoped: `<prefix>--observability-<component>` (the aggregator keeps `stack--observability`). Options are `services.observability-<component>`; the aggregator is `services.observability`.
3. The old names remain as generated, deprecated aliases for one minor release (0.3.x) and are removed in 0.4.0.
4. Systemd unit names, users, groups, directories and generated file names do not change.

## Alternatives considered
- Generic names (`servc--loki`): collision risk. Keep the `-nixlab` suffix: misleading. Nested options (`services.observability.loki`): collides with the aggregator's own options.

## Consequences / migration
Consumers set the new option names; old ones warn until 0.4.0. nixlab migrates in two stages (Guide 3, Part 10).
