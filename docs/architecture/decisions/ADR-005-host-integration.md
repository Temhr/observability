# ADR-005: Host integration contract

- **Status:** Accepted (2026-11-17)
- **Related:** ADR-006, ADR-009

## Context

At extraction time the modules depended on facts only `nixlab` provides: `nixlabLib` and `hostMeta`/`allHosts` as `specialArgs`, `config.nixlab.mainUser`, and `self.lib.hostsMeta` / `self.lib.serviceRegistry` from the main flake. Special arguments are untyped, undiscoverable, bypass the option system, and fail with unhelpful errors for any consumer that does not supply them. Version 0.1 carried these as documented, temporary seams.

## Decision

1. **The flake takes no special arguments.** Everything a module needs arrives through the NixOS module system (`config`, `lib`, `pkgs`, `options`) or typed options.
2. **The flake reads no consumer metadata** and declares no dependency on any option it does not define itself. Host address, gateway, interface names, users, mounts and probe targets are *options*.
3. **Translation lives in the consumer.** A consumer adapter module (for nixlab: `stack--observability-nixlab`) maps local facts onto public options. The adapter contains no service logic and no duplicated wiring.
4. **Defaults are policy, not coupling.** Services provide safe defaults, the stack aggregator uses `mkDefault`, consumers override. Adapters use `mkDefault` for values that were option defaults; list options that must merge (`extraUsers`) are assigned plainly.
5. **Enforcement is mechanical:** the `no-nixlab-coupling` flake check, and a test harness that passes no `specialArgs` and builds a host with no `nixlab` options.

## Alternatives considered

- **Keep a documented specialArgs contract.** Rejected: hidden, untyped, breaks any consumer that forgets one, and cannot be validated by assertions.
- **Depend on nixlab as a flake input.** Rejected: circular, and defeats independence.
- **Accept a whole host-metadata attrset as one option.** Rejected: couples the stack to nixlab's schema; expose each needed value directly.

## Consequences

- Consumers must set a few options an integrated setup used to get implicitly (`publicHost`, `probes.gateway`, `extraUsers`). The adapter does it for nixlab.
- A single place (the adapter) knows both domains, which makes the relationship auditable.

## Migration implications

0.1 → 0.2 removes the seams listed in the Guide 2 seam map. External consumers of 0.1 (none known) would have had to supply the special arguments; 0.2 simply stops needing them.
