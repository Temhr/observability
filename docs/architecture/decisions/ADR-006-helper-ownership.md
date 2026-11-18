# ADR-006: Helper ownership

- **Status:** Accepted (2026-11-17)
- **Related:** ADR-005

## Context

The services use six shared helpers originally defined in nixlab's `nixlabLib`: `mkServiceHardening`, `mkDataDirPermissionsService`, `mkWalSelfHeal`, `mkNginxVirtualHost`, `mkFirewallPorts`, `mkSslAssertion`. All six are used by the observability modules (nginx/firewall/SSL by every service that has `domain` or `openFirewall`; the others by the rest). `mkServiceHardening` and `mkDataDirPermissionsService` encode security and state-ownership invariants.

## Decision

1. **The observability flake owns its helpers** as `flake.lib.obsLib`, copied from nixlab with function bodies unchanged at the point of the move.
2. **Modules read the helpers from the flake-parts scope** (`self.lib.obsLib`), not through a module argument.
3. **The two copies may diverge** after the move. nixlab keeps `nixlabLib` for its own modules; neither is a dependency of the other.
4. **`obsLib` is internal until 1.0.** It is visible in `self.lib` but carries no compatibility promise.
5. **A shared helper flake is not created** unless a second independent consumer demonstrably needs the same API.

## Alternatives considered

- **Shared third repository.** Rejected for now: three repositories to avoid maintaining a few hundred lines, and a lockstep versioning burden.
- **Import nixlab's helpers via a flake input.** Rejected: circular dependency.
- **Inline helpers into every module.** Rejected: duplicates security-relevant code six-plus times.
- **Move only the "observability-specific" helpers.** Not possible: all six are in use.

## Consequences

- A security fix to hardening must be applied in each repository that carries its own copy.
- Simplifying or splitting the helpers is possible later without touching nixlab.

## Migration implications

Guide 2, Part 3: rename `nixlabLib` to `obsLib`, bind from scope, delete the special-argument plumbing. Guide 3 may review the hardening defaults and exceptions (JIT, `/proc`, device access) as a documented contract.
