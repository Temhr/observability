# Public API (v0.2)

## Stability
Pre-1.0: a minor version may break. Everything not listed under "Public" is internal.

## Public NixOS modules (names are the contract)
| Module | Purpose | Enabled by |
|---|---|---|
| stack--observability | the whole stack, wired | services.nixlab-observability.enable |
| servc--{prometheus,alertmanager,ntfy,loki,alloy,grafana}-nixlab | single services, usable alone | services.<name>-nixlab.enable |
| systm--host-exporters-nixlab, systm--maintenance-log-nixlab, systm--observability-backup-nixlab | supporting capabilities | own `enable` |
| nsops--alertmanager, nsops--grafana | OPTIONAL sops-nix integration | services.{alertmanager,grafana}-nixlab.enable + secretsFile |

Importing a module never starts anything; each has an `enable`.

## Consumer-supplied (no defaults that assume your environment)
- Nothing is required except `enable`.
- If ntfy auth is on: `notifications.ntfyAuth.environmentFile` (defaults to alertmanager's `environmentFile`).
- If you use the nsops modules: `secretsFile` per service, and sops-nix configured with a key source.
- If you want remote access: `access.interfaces` (default: loopback only).
- Optional context: `publicHost`, `probes.gateway`, `probes.icmpTargets`, `probes.tcpTargets`, `*.extraUsers`.

## Host prerequisites (documented, not enforced)
state root (`dataDir`, default /data/observability) is mounted before the stack starts;
time sync reaches `time-sync.target`; journald; nginx only if a service sets `domain`;
a firewall only if you use `access.interfaces`/`openFirewall`.

## Internal (no promise)
`self.lib.obsLib`, `_internals/`, ports modules (`systm--ports-*`), harness.
