# Public API (v0.3)

## Stability

Pre-1.0: a minor release may break. Everything not listed under **Public** is internal. A name that is renamed keeps working, with a warning for options, for one minor release (see [Deprecated names](#deprecated-names)). Design decisions behind the names are in [ADR-010](decisions/ADR-010-final-names.md).

## Public

### NixOS modules (the names are the contract)

Exported as `observability.nixosModules.<name>`. Importing a module never starts anything; each has an `enable`. Modules can be imported alone, together, or through the stack, in any combination (see [Module keys](#module-keys)).

| Module | Purpose | Enabled by |
|---|---|---|
| `stack--observability` (also exported as `default`) | the whole stack, wired together | `services.observability.enable` |
| `servc--observability-prometheus` | metrics, rules, blackbox exporter | `services.observability-prometheus.enable` |
| `servc--observability-alertmanager` | routing, inhibition, receivers | `services.observability-alertmanager.enable` |
| `servc--observability-ntfy` | push notification server | `services.observability-ntfy.enable` |
| `servc--observability-loki` | log store and LogQL ruler | `services.observability-loki.enable` |
| `servc--observability-alloy` | log shipper | `services.observability-alloy.enable` |
| `servc--observability-grafana` | dashboards | `services.observability-grafana.enable` |
| `systm--observability-host-exporters` | node and smartctl exporters | `services.observability-host-exporters.nodeExporter.enable` and `.smartctl.enable` (the Prometheus module sets them from its own options) |
| `systm--observability-maintenance-log` | maintenance log, CLI and metrics | `services.observability-maintenance-log.enable` |
| `systm--observability-backup` | nightly copies of service state | `services.observability-backup.enable` |
| `nsops--observability-alertmanager`, `nsops--observability-grafana` | **optional** [sops-nix](https://github.com/Mic92/sops-nix) wiring | act when the service is enabled; need `secretsFile` |

### Option namespaces

| Namespace | Owner |
|---|---|
| `services.observability` | the stack (aggregator): `enable`, `listenAddress`, `publicHost`, `access.*`, `probes.*`, `openFirewall`, `dataDir`, `loki.*`, `prometheus.*`, `ntfy.*`, `notifications.*`, `integrations.*` |
| `services.observability-<component>` | one per service module above, e.g. `services.observability-loki` |

Every documented option is public: its name, type and meaning. The complete list, with defaults and descriptions, is generated from the code in [`../reference/options.md`](../reference/options.md). An option that is not in that reference is internal.

### Flake outputs

| Output | Status |
|---|---|
| `nixosModules.*` | public (above) |
| `packages.<system>.{mon-check,mon-snapshot,mon-unitdiff}` and the matching `apps` | public; command-line interface and exit codes are stable |
| `lib.observabilityHostChecks` | supported for consumers' CI (nixlab uses it), but its argument set may change in a minor release |
| everything else under `packages`, `checks`, `lib` | internal (see [Internal](#internal-no-promise)) |

### State and service identity

Persistent paths, unit names and users are part of the contract: a release does not move data or rename a unit. `<dataDir>` is `services.observability.dataDir` (default `/data`).

| Item | Value |
|---|---|
| State directories | `<dataDir>/prometheus`, `<dataDir>/loki`, `<dataDir>/grafana`, `<dataDir>/ntfy`, `<dataDir>/backup`; `/var/lib/alloy`; `/var/lib/private/alertmanager`; `/var/lib/node_exporter/*.prom` (textfile metrics); `/var/log/maintenance.jsonl` |
| Systemd units | `prometheus`, `loki`, `alloy`, `grafana`, `alertmanager`, `ntfy`, `ntfy-provision`, `prometheus-node-exporter`, `prometheus-smartctl-exporter`, `observability-backup`, `maintenance-log-metrics`, plus `<service>-permissions` and `<service>-wal-recover` helpers |
| Users (stack-pinned uid) | `loki` 740, `alloy` 741, `grafana` 742, `prometheus` 743, `ntfy` 744; Alertmanager runs with `DynamicUser` |
| Default ports | Prometheus 9090, Alertmanager 9093 (gossip 9094, off unless peers are set), Grafana 3101, Loki 3100 (gRPC 9096, loopback), ntfy 2586, Alloy 12345 (loopback), node 9100, smartctl 9633, blackbox 9115, systemd exporter 9558 |

Port precedence: a host's plain assignment beats the option default. There are no per-service port modules.

### Alerting and dashboard interface

What consumers route, silence and link to is stable. Expressions and thresholds are not.

- **Alert names.** Each Prometheus and Loki-ruler alert has a runbook at `docs/runbooks/<AlertName>.md`; renaming or removing an alert is a breaking change.
- **Alert labels.** `severity` (`warning` or `critical`), `category`, `checklist_section`, and the `host` external label. The `condition` label and the `runbook` annotation are generated.
- **Notification topics.** `<notifications.ntfyTopic>` (default `alerts`) and one `<ntfyTopic>-<name>` per entry in `notifications.topics`.
- **Datasource uids** (dashboards reference them): `prometheus`, `loki`, `alertmanager`. **Dashboard uids:** `system-maintenance-overview-v5`, `zfs-pool-monitoring`.
- **Log labels** produced by Alloy: `job` (`systemd-journal`, `varlogs`, `maintenance-log`), `host`, `unit`, `level`, `transport`.

### Secret interface

No module references a secret manager. Secrets are **file paths**: `services.observability-alertmanager.environmentFile`, `services.observability-grafana.credentialsFile` and `.secretKeyFile`, `services.observability.notifications.ntfyAuth.environmentFile`. The optional `nsops--observability-*` modules declare the sops secrets and set these paths from `secretsFile`. The repository contains no secret material.

## Guarantees

### Module keys

Every public module carries a stable `key`, so NixOS applies it once however it is reached: importing `servc--observability-loki` and `stack--observability` together is valid and does not declare options twice.

### Side effects of `domain`

Setting `services.observability-<component>.domain` enables nginx and adds a virtual host for that domain that proxies to the service; `enableSSL` additionally requests a certificate (ACME) and forces HTTPS. When that service's `openFirewall` is true it opens ports **80 and 443** instead of the service port. With the stack, per-service `openFirewall` follows `services.observability.openFirewall` (default `false`). This behaviour is pinned by a test, so a change to it is a breaking change.

### Maintenance log label

`services.observability-maintenance-log.lokiJob` (default `maintenance-log`) is the Loki `job` label of the maintenance log. The stack uses it for Alloy's label and for Loki's two-year retention stream, and the bundled system-overview dashboard queries the default value.

## Consumer-supplied (no defaults that assume your environment)

- A default install works but emits the warning `services.observability-grafana: secretKeyFile is not set…` until `services.observability-grafana.secretKeyFile` is set.
- If ntfy auth is on (`services.observability.notifications.ntfyAuth.enable`): `notifications.ntfyAuth.environmentFile`, which defaults to `services.observability-alertmanager.environmentFile`.
- If you use the `nsops--observability-*` modules: `services.observability-alertmanager.secretsFile` and `services.observability-grafana.secretsFile`, and sops-nix configured with a key source.
- If you want remote access: `services.observability.access.interfaces` (default: loopback only). Interface names must be non-empty.
- Optional context: `services.observability.publicHost`, `services.observability.probes.{gateway,icmpTargets,tcpTargets}`, and `services.observability-<component>.extraUsers` (users who get read access to a service's data).

## Host prerequisites (documented, not enforced)

The state root (`dataDir`, default `/data`, with `/data/<service>` below it) is mounted before the stack starts; time sync reaches `time-sync.target`; journald is running; nginx is needed only if a service sets `domain`; a firewall is needed only if you use `access.interfaces` or `openFirewall`. The optional ZFS alerts need the textfile metrics described in [`../operations/zfs-metrics.md`](../operations/zfs-metrics.md).

## Internal (no promise)

`self.lib.obsLib` (including `keyed`), `self.lib.{prometheusRendered,prometheusMaintenanceAlerts,lokiRendered,alloyRendered,grafanaDashboards,maintenanceLoggerScript}`, everything under `_internals/`, the test harness, the `compat` modules (`compat-options`, `compat-sops-options`; deprecated shims, removed in 0.4.0), and the development outputs (`packages.vm-smoke`, `packages.options-doc`, `packages.goldens`, `packages.fingerprint`, `checks.*`).

## Deprecated names

Deprecated in 0.3.0 and **removed in 0.4.0**. Old **option** names keep working and print a warning when used; old **module** names keep working without a warning (a flake output cannot warn). Migrate by replacing the left column with the right.

### Module names

| Old (0.2) | New |
|---|---|
| `servc--prometheus-nixlab` | `servc--observability-prometheus` |
| `servc--alertmanager-nixlab` | `servc--observability-alertmanager` |
| `servc--ntfy-nixlab` | `servc--observability-ntfy` |
| `servc--loki-nixlab` | `servc--observability-loki` |
| `servc--alloy-nixlab` | `servc--observability-alloy` |
| `servc--grafana-nixlab` | `servc--observability-grafana` |
| `systm--host-exporters-nixlab` | `systm--observability-host-exporters` |
| `systm--maintenance-log-nixlab` | `systm--observability-maintenance-log` |
| `systm--observability-backup-nixlab` | `systm--observability-backup` |
| `nsops--alertmanager` | `nsops--observability-alertmanager` |
| `nsops--grafana` | `nsops--observability-grafana` |

`stack--observability` is unchanged.

### Option namespaces

Every option under an old namespace maps to the same option under the new one (for example `services.loki-nixlab.retention` is now `services.observability-loki.retention`).

| Old (0.2) | New |
|---|---|
| `services.nixlab-observability` | `services.observability` |
| `services.prometheus-nixlab` | `services.observability-prometheus` |
| `services.alertmanager-nixlab` | `services.observability-alertmanager` |
| `services.ntfy-nixlab` | `services.observability-ntfy` |
| `services.loki-nixlab` | `services.observability-loki` |
| `services.alloy-nixlab` | `services.observability-alloy` |
| `services.grafana-nixlab` | `services.observability-grafana` |
| `services.host-exporters-nixlab` | `services.observability-host-exporters` |
| `services.maintenance-log-nixlab` | `services.observability-maintenance-log` |
| `services.observability-backup-nixlab` | `services.observability-backup` |

## Changes in 0.3

### Breaking

| Change | What to do |
|---|---|
| Module and option names (above) | rename; the old names work until 0.4.0 |
| The NVIDIA Xid log alert (`NvidiaXid`) is **opt-in**; it used to be always on | set `services.observability.integrations.nvidia.enable = true;` on hosts with the NVIDIA driver |
| The six ZFS member and scrub alerts (`ZpoolDeviceErrors`, `ZpoolDataErrors`, `ZpoolScrubOverdue`, `ZpoolScrubErrors`, `ZpoolMemberMissing`, `ZpoolMemberReonlined`) are **opt-in**; they used to load whenever maintenance alerts were on | set `services.observability-prometheus.maintenance.alerts.features.zfsMembers = true;` and provide the textfile metrics |
| A standalone Loki (without the stack) no longer applies the two-year retention to `{job="maintenance-log"}` by default | the stack sets it through `services.observability-loki.retentionStreams`; standalone users set it themselves |
| The dashboard's "Time since each timer last fired" panel filters on `services.observability-grafana.timersRegex`, default `nixos-upgrade.timer\|nix-gc.timer` | set `timersRegex` to the timers you want shown |
| The 0.2 aliases `loki-nixlab.{enableAlloy,alloyPort,alloyPackage}` and `loki-nixlab.maintenance.{enable,logPath}` are removed | use `services.observability-alloy.{enable,port,package}` and `services.observability-maintenance-log.{enable,logPath}` |

### Fixed

`services.observability-alloy.extraUsers` and `services.observability-prometheus.extraUsers` failed evaluation in 0.2.0 (fixed in 0.2.1).

### Added

`default` module; stable module keys; options `services.observability-loki.retentionStreams`, `services.observability-maintenance-log.lokiJob`, `services.observability.integrations.nvidia.enable`, `services.observability-prometheus.maintenance.alerts.features.zfsMembers`, `services.observability-grafana.timersRegex`; hermetic `mon-check`, `mon-snapshot`, `mon-unitdiff` packages.

### Internal (not API)

Per-service port modules (`systm--ports-*`) are gone; ports are option defaults with the same values. The repository layout is flattened to `modules/nixos/<service>/`.

## History: breaking changes in 0.2

Names are as they were in 0.2; see [Deprecated names](#deprecated-names) for today's.

| Change | Replacement | Alias? |
|---|---|---|
| The flake no longer reads `nixlabLib`, `hostMeta`, `allHosts`, `config.nixlab.mainUser` | the options below | n/a (never public) |
| `probes.hosts`, `probes.tcpFromRegistry` removed | `probes.icmpTargets`, `probes.tcpTargets` | no |
| `loki-nixlab.{enableAlloy,alloyPort,alloyPackage}` | `alloy-nixlab.{enable,port,package}` | removed in 0.3 |
| `loki-nixlab.maintenance.{enable,logPath}` | `maintenance-log-nixlab.{enable,logPath}` | removed in 0.3 |
| The stack no longer imports `nsops--*` | import them yourself | no |
| `secretsFile` has no default | set it | no |
| `mainUser` no longer gets implicit access | set `extraUsers` | no |
| `publicHost` and `probes.gateway` default to `null` | set them | no |
| New option `prometheus-nixlab.runbookBaseUrl` | | n/a |
| New option `notifications.ntfyAuth.environmentFile` | | n/a |
| New assertion: no empty names in `access.interfaces` | | n/a |
