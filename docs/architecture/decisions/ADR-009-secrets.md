# ADR-009: Secrets integration

- **Status:** Accepted (2026-11-17)
- **Related:** ADR-005

## Context

Alertmanager and ntfy need credentials (notification-provider keys, ntfy user passwords), and Grafana needs an admin password and a secret key. nixlab supplies them with sops-nix. In 0.1 the stack imported the sops modules, assigned into `sops.secrets` directly, and the sops modules defaulted `secretsFile` to an encrypted file in the nixlab repository. That made sops-nix and nixlab's file layout hard requirements.

## Decision

1. **Service and stack modules never reference sops.** They accept secret *file paths* as options (`services.alertmanager-nixlab.environmentFile`, `services.grafana-nixlab.credentialsFile`, `services.grafana-nixlab.secretKeyFile`, `services.nixlab-observability.notifications.ntfyAuth.environmentFile`).
2. **The `nsops--alertmanager` and `nsops--grafana` modules are optional integrations.** They declare the sops secrets, set owner/group/restart behaviour and wire the resulting paths into the options above. A consumer imports them only if it uses sops-nix. The stack does not import them.
3. **`secretsFile` has no default.** The encrypted file belongs to the consumer.
4. **Restart wiring lives with the secret manager.** "Rotated secret re-runs ntfy-provision" is expressed in the sops module, not the stack.
5. **ntfy auth defaults to the Alertmanager environment file**, since both need the same credentials; it can be overridden.
6. **The consumer owns:** encrypted values, age recipients, `.sops.yaml`, machine key locations. The repository contains no secret material, only dummy values in tests and docs.
7. **sops-nix stays a flake input** for the optional modules and the test harness; it is not a runtime requirement.

## Alternatives considered

- **Hard-require sops-nix.** Rejected: excludes consumers using other secret managers.
- **Ship encrypted files in the repository.** Rejected: ties recipients and keys to one owner.
- **Support several secret managers inside the flake.** Rejected: scope creep; the path options already allow any manager.

## Consequences

- nixlab's adapter imports the `nsops--*` modules and sets `secretsFile`.
- A secret rotation is documented per credential (name, format, consumer, restart behaviour, validation without printing values).
- Test coverage includes a host with no sops-nix at all.

## Migration implications

Guide 2, Part 7. After it, the `external` harness host (no sops-nix) must build, which is the acceptance test for this ADR.
