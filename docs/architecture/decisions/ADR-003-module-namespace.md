# ADR-003: Module and option namespace

- **Status:** Accepted (2026-11-17)
- **Deciders:** repository owner
- **Related:** ADR-005, Guide 3 (rename phase)

## Context

The flake exports modules named with a category prefix and a `-nixlab` suffix (`servc--loki-nixlab`, `systm--maintenance-log-nixlab`, `stack--observability`, `nsops--grafana`). Options use matching namespaces (`services.loki-nixlab.*`, `services.nixlab-observability.*`). The suffix reflects where the code started, not what it is. Outside consumers will find it odd.

Module names and option paths are the flake's public contract: consumers reference them directly, so changing them is a breaking change even when evaluation still succeeds.

## Decision

1. **Through the 0.x extraction and decoupling milestones, names and option namespaces do not change.** The canonical public names are the ones exported today.
2. **Names are the API; file locations are not.** Moving or splitting files must never change an exported name.
3. **Renaming is a deliberate, separately versioned change** made in Guide 3, with `lib.mkRenamedOptionModule` aliases kept for one minor release.
4. The naming scheme (`servc--` single service, `systm--` supporting capability, `stack--` aggregator, `nsops--` optional sops wiring) is kept.
5. Whether the final names are generic (`servc--prometheus`) or product-scoped (`observability--prometheus`) must be decided **before 1.0**, and recorded in a superseding ADR.

## Alternatives considered

- **Rename during extraction.** Rejected: it mixes a rename with a move, invalidates the parity comparison, and forces host-file edits.
- **Generic names now.** Deferred, not rejected. The collision risk with other flakes' modules needs thinking through, and nothing forces the choice yet.

## Consequences

- External users see a `-nixlab` suffix that is misleading. The README and `public-api.md` must say so explicitly until the rename.
- Zero host edits are needed during extraction and decoupling.

## Migration implications

None now. At rename time: add aliases, list every renamed option in `CHANGELOG.md` under "Breaking changes", and bump the minor version.
