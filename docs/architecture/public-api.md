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
- A default install works but emits the warning `services.grafana-nixlab: secretKeyFile is not set…` until grafana-nixlab.secretKeyFile is set
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

## Breaking changes in 0.2:
| Change | Replacement | Alias? |
|---|---|---|
| The flake no longer reads nixlabLib, hostMeta, allHosts, config.nixlab.mainUser | options below | n/a (never public) |
| probes.hosts, probes.tcpFromRegistry removed | probes.icmpTargets, probes.tcpTargets | no |
| oki-nixlab.{enableAlloy,alloyPort,alloyPackage} | alloy-nixlab.{enable,port,package} | yes, until 0.3 |
| loki-nixlab.maintenance.{enable,logPath} | maintenance-log-nixlab.{enable,logPath} | yes, until 0.3 |
| The stack no longer imports nsops--* | import them yourself | no |
| secretsFile has no default | set it | no |
| mainUser no longer gets implicit access | set extraUsers | no |
| publicHost/probes.gateway default to null | set them | no |
| New option prometheus-nixlab.runbookBaseUrl |  | n/a |
| New option notifications.ntfyAuth.environmentFile |  | n/a |
| New assertion: no empty names in access.interfaces |  | n/a |

