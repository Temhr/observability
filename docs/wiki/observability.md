# Observability Stack — Architecture & Reference

> **Scope.** Everything this flake ships: `modules/nixos/<service>/`, `stacks/`, `sops/{alertmanager,grafana}.nix`, `flake/lib/obs-lib.nix` (the helpers the stack uses), `flake/ci/` (checks and the test harness), `bin/mon-*.sh`, `compat/` (deprecated names, removed in 0.4.0) and `docs/runbooks/`.
> **Basis.** Written from the code as of **v0.3** (November 2026).
> **Companion docs.** `docs/architecture/public-api.md` (what is stable), `docs/reference/options.md` (every option, generated), `docs/architecture/decisions/` (ADRs), `docs/operations/zfs-metrics.md`, and `docs/runbooks/*.md` (one page per alert).
> **Staleness rule.** If this file and the code disagree, the code wins. Open questions and design decisions live in the ADRs and `CHANGELOG.md`.

---

## Table of Contents

0. [Context card (paste this into an LLM prompt)](#0-context-card)
1. [Overview](#1-overview)
2. [Design principles and why](#2-design-principles-and-why)
4. [File map](#4-file-map)
5. [The aggregator: `stack--observability`](#5-the-aggregator-stack--observability)
6. [Component reference](#6-component-reference)
7. [Alerting reference](#7-alerting-reference)
8. [Data flows](#8-data-flows)
9. [Secrets](#9-secrets)
10. [Runtime layout](#10-runtime-layout-what-is-where-on-a-host)
11. [Shared helpers (`obsLib`)](#11-shared-helpers-obslib)
12. [Resilience mechanisms](#12-resilience-mechanisms)
13. [CI and testing](#13-ci-and-testing)
14. [Operations](#14-operations)
15. [Extending the stack](#15-extending-the-stack)
17. [Quick reference](#17-quick-reference)
18. [Appendix: illustrative host configuration](#appendix-illustrative-host-configuration)

---

## 0. Context card

*Self-contained summary. If you only paste one section into a prompt, paste this one; paste the whole file for deep work.*

**What it is.** A self-hosted observability stack as a NixOS flake (flake-parts + import-tree, self-registering modules), extracted from the nixlab repository and independent of it. Components: **Prometheus** (metrics + alert rules), **Alertmanager** (routing/inhibition), **ntfy** (push notifications), **Loki** (logs + LogQL ruler), **Grafana Alloy** (log shipper), **Grafana** (dashboards), plus **node_exporter**, **smartctl_exporter**, **blackbox_exporter**, and a **maintenance-log** helper that records manual maintenance tasks as JSON lines.

**Shape.** Each component is an *atomic* NixOS module (`servc--observability-<x>`, options at `services.observability-<x>.*`) with no knowledge of its siblings. All cross-service wiring (datasources, scrape jobs, receivers, ruler → Alertmanager, uids, URLs, firewall, backups) lives in **one aggregator module** `stack--observability` (also exported as `default`; `stacks/observability.nix`, options at `services.observability.*`). A host enables `services.observability.enable = true` and gets everything. Supporting modules are `systm--observability-{host-exporters,maintenance-log,backup}`; optional sops-nix wiring is `nsops--observability-{alertmanager,grafana}`.

**Defaults.** Stack defaults: scrape interval 30 s, Prometheus retention 15 d, Loki retention 744 h (maintenance log kept 2 years); `access.expose = [grafana ntfy prometheus]`, but `access.interfaces` is empty, so everything is loopback-only until interfaces are set.

**Data flow.** exporters → Prometheus → (rules) → Alertmanager → webhook → ntfy topic `alerts` → phone/browser. Journald + `/var/log/*.log` + maintenance log → Alloy → Loki → (ruler alerts) → Alertmanager. Grafana reads Prometheus, Loki, Alertmanager (uids `prometheus`, `loki`, `alertmanager`).

**Config generation pattern.** Nix attrset → `builtins.toJSON` → `remarshal` → YAML written into the service's `dataDir` (default `/data/<svc>`) at service start (`preStart`/`ExecStartPre`). Config is regenerated on every start; do not hand-edit generated files. The Prometheus, Loki and Alloy configs are also exposed to CI (`flake.lib.{prometheusRendered,lokiRendered,alloyRendered}`) so they are validated at build time.

**Ports.** ntfy 2586, Loki 3100 (gRPC 9096 loopback), Grafana 3101, Prometheus 9090, Alertmanager 9093, node 9100, smartctl 9633, blackbox 9115, systemd-exporter 9558 (off), Alloy 12345 (loopback). They are the options' own defaults; a host's plain assignment wins.

**Exposure model.** Everything binds loopback unless a service is listed in `access.expose` *and* `access.interfaces` is non-empty (then `0.0.0.0` + per-interface firewall rules on the named interfaces). `openFirewall` (all interfaces) defaults to false. Alertmanager always posts to the *local* ntfy. **Prometheus, Loki and Alertmanager have no authentication; Grafana has a login; ntfy is open unless `notifications.ntfyAuth.enable` is set.** Name only interfaces you trust.

**Alerts.** About 68 Prometheus alert rules in `_internals/maintenance-alerts.nix` (62 always-available plus six opt-in ZFS member and scrub alerts), grouped by maintenance-checklist section (labels `severity`, `category`, `checklist_section`), plus 4 Loki-ruler alerts defined in the stack (one of them, `NvidiaXid`, opt-in). Core groups (stack self-health, recording rules) always load; the rest load only if `services.observability.prometheus.maintenance.enable = true` (default `false`). Every alert, Prometheus or Loki, needs `docs/runbooks/<Alert>.md` or an entry in `docs/runbooks/_todo.txt` (CI-enforced). Deployed alerts carry a `condition` label (own expr + `for`) and a `runbook` annotation (URL built from `services.observability-prometheus.runbookBaseUrl`).

**Resilience.** Prometheus can stay "healthy" while storing nothing (for example after a clock jump). Mitigations: services order after `time-sync.target` (which the host must make wait for NTP, e.g. via `systemd-time-wait-sync`); `prometheus-tsdb-guard` timer quarantines a wrong-time WAL/head; `mkWalSelfHeal` quarantines a corrupt WAL after crash loops (Prometheus and Loki); `absent_over_time` self-alert; inhibition of all `observability` alerts while `PrometheusNoRecentSamples` fires.

**Stability.** Pre-1.0. Module names, documented options, state paths, unit names and uids are a contract (`docs/architecture/public-api.md`). The 0.2 `-nixlab` option and module names are **deprecated aliases until 0.4.0** (`compat/`); everything in this file uses the new names. Every public module has a stable `key`, so modules can be imported alone, together, or through the stack.

**Verification.** `nix flake check` (promtool config/rules/tests, amtool, Loki/Alloy config validation, dashboard lint, shellcheck, runbook coverage, contract tests, docs freshness); `nix build .#vm-smoke` boots a VM with the full stack (needs KVM); on a host `nix run .#mon-check [-- --fire-test]` (or `bin/mon-check.sh`); `mon-snapshot` and `mon-unitdiff` for before/after comparisons.

---

## 1. Overview

### 1.1 Component diagram

```
                              ┌──────────────────────────── one host running the full stack ───────────────────────┐
                              │                                                                                    │
  /var/log/*.log ─┐           │                                  ┌───────────────┐                                 │
  journald ───────┼─► Alloy ──┼──── push :3100 ───────────────►  │     Loki      │ ◄──── LogQL ───┐                │
  maintenance     │ (lo:12345)│                                  │ (+ ruler)     │                │                │
  .jsonl ─────────┘           │                                  └──────┬────────┘                │                │
                              │                                         │ ruler alerts            │                │
  node_exporter :9100 ─┐      │                                         ▼                         │                │
  smartctl      :9633 ─┤      │                                  ┌───────────────┐          ┌─────┴──────┐         │
  blackbox      :9115 ─┼──────┼─ scrape ► ┌────────────┐ alerts► │ Alertmanager  │ webhook► │    ntfy    │ ► phone │
  ntfy/loki/grafana/  ─┤      │           │ Prometheus │ ──────► │   :9093       │ :2586    │  topic     │         │
  alertmanager/alloy  ─┘      │           │   :9090    │         └───────────────┘ /alerts  │  "alerts"  │         │
  (/metrics)                  │           └─────┬──────┘                                    └────────────┘         │
  textfile: maintenance.prom ─┘                 │ datasource                                                       │
  textfile: backup_metrics.prom                 ▼                                                                  │
  textfile: zfs *.prom (opt.) │          ┌───────────┐  datasources: Prometheus(uid prometheus, default),          │
                              │          │  Grafana  │  Loki(uid loki), Alertmanager(uid alertmanager)             │
                              │          │   :3101   │                                                             │
                              │          └───────────┘                                                             │
                              └────────────────────────────────────────────────────────────────────────────────────┘
```

### 1.2 Components at a glance

| Component | Module (`observability.nixosModules.<name>`) | Options namespace | systemd unit(s) | Role |
|---|---|---|---|---|
| Prometheus | `servc--observability-prometheus` | `services.observability-prometheus` | `prometheus`, `prometheus-permissions`, `prometheus-tsdb-guard` (+timer), `prometheus-wal-recover`, `backup-status-exporter` (opt.) | Scrapes, stores, evaluates alert + recording rules |
| Host exporters | `systm--observability-host-exporters` | `services.observability-host-exporters` | `prometheus-node-exporter`, `prometheus-smartctl-exporter` | Machine metrics (node, SMART) |
| Alertmanager | `servc--observability-alertmanager` (+ `nsops--observability-alertmanager`) | `services.observability-alertmanager` | `alertmanager` (upstream module) | Group, route, inhibit, deliver |
| ntfy | `servc--observability-ntfy` | `services.observability-ntfy` | `ntfy`, `ntfy-permissions`, `ntfy-provision` | Push notification server |
| Loki | `servc--observability-loki` | `services.observability-loki` | `loki`, `loki-permissions`, `loki-wal-recover` | Log store + LogQL ruler |
| Alloy | `servc--observability-alloy` | `services.observability-alloy` | `alloy`, `alloy-permissions` | Ships journal, `/var/log/*.log`, maintenance log to Loki |
| Grafana | `servc--observability-grafana` (+ `nsops--observability-grafana`) | `services.observability-grafana` | `grafana`, `grafana-permissions` | Dashboards; provisions datasources + dashboards |
| Maintenance log | `systm--observability-maintenance-log` | `services.observability-maintenance-log` | `maintenance-log-metrics` (+timer) | `maintenance-log` CLI, JSONL file, completion metrics |
| Backup | `systm--observability-backup` | `services.observability-backup` | `observability-backup` (+timer) | Nightly consistent copies of state |
| **Aggregator** | `stack--observability` (also `default`) | `services.observability` | — | Wires all of the above together |

---

## 2. Design principles and why

1. **Atomic modules, one aggregator.** Grafana must know Prometheus and Loki exist; Prometheus must know where Alertmanager is; Alertmanager must know ntfy. If any service module knew its siblings, none could be reused or tested alone. So each `servc--*` module only declares its own options and exposes *escape hatches* (`extraScrapeConfigs`, `alertmanagerTargets`, `provisioning.datasources`, `receivers`, `route.routes`, `ruler.groups`, `retentionStreams`, `extraConfig`), and the stack fills them (ADR-005).
2. **Config as typed Nix, rendered at start.** Each service builds a Nix attrset, serialises to JSON, converts to YAML with `remarshal`, and installs it in `dataDir`. Reason: the data lives on a separate `/data` mount, configs must be inspectable on the host, and the same attrsets can be rendered and validated at *build time* in CI (`flake.lib.prometheusRendered`, `lokiRendered`, `alloyRendered`).
3. **Delegate where upstream is good, own the unit where it isn't.** Alertmanager, smartctl, blackbox and systemd exporters use the upstream NixOS modules (DynamicUser, amtool check, envsubst). Prometheus, Loki, Alloy, Grafana, ntfy and node_exporter are custom units so that paths, uids, hardening, ordering and self-healing are uniform.
4. **Loopback by default; expose explicitly.** Some machines route over Wi-Fi, so exposure is by *named interface* (`access.interfaces`; policy in ADR-008) not by blanket `openFirewall`.
5. **Observability must survive its own failure modes.** Prometheus can stay healthy (`/-/healthy` OK) while rejecting every sample, for example after a clock jump; rules that depend on stored metrics can't catch that. `absent_over_time`, a time-sync ordering, a TSDB guard, WAL self-heal, and an inhibit rule exist for this.
6. **Every alert is actionable and documented.** Alerts carry a checklist section, a runbook link and the exact condition that fired; CI refuses an alert with no runbook.
7. **Manual maintenance is data.** The "maintenance checklist" (31 sections) is mirrored in `checklist.nix`; completed tasks are logged as JSONL, shipped to Loki (2-year retention) and turned into last-completed metrics for the dashboard.
8. **Every host is self-contained.** No host scrapes, probes or ships logs to another by default; the same configuration runs everywhere and differences come from hardware and per-host overrides.
9. **Reproducible, verifiable deploys.** Pinned uids, ordered units, CI checks, a VM smoke test, and `mon-*` scripts that compare before/after state.
10. **Precedence is explicit.** Stack tunables are `lib.mkDefault`: override with `services.observability.*` *or* directly on `services.observability-<x>.*`. Wiring (datasources, scrape jobs, receivers, targets) is plain and additive: extend, don't replace. Ports are option defaults; a host's plain assignment wins.
11. **One owner per setting.** The module that owns a fact exposes it as an option and everyone else reads it (the textfile directory belongs to host-exporters, the maintenance-log label to the maintenance-log module, a port to its service). Names, state paths, unit names and uids are a published contract (`public-api.md`, ADR-010).
12. **Nothing specific to one deployment.** Anything that only suits one fleet is an option that defaults off (the NVIDIA alert, the ZFS member alerts, the dashboard's timer list); the consumer's adapter switches it on.

---

## 4. File map

```
stacks/observability.nix                                  stack--observability (aggregator)
stacks/default.nix                                        exports it as `default`
modules/nixos/
├── alertmanager/default.nix                           servc--observability-alertmanager
├── alloy/default.nix                                  servc--observability-alloy, flake.lib.alloyRendered
├── alloy/_internals/rendered.nix                      the base Alloy pipeline text
├── grafana/default.nix                                servc--observability-grafana, flake.lib.grafanaDashboards
├── grafana/dashboards/{system-overview-v5,zfs-monitoring}.json
├── host-exporters/default.nix                         systm--observability-host-exporters
├── loki/default.nix                                   servc--observability-loki, flake.lib.lokiRendered
├── loki/_internals/rendered.nix                       the Loki config attrset
├── maintenance-log/default.nix                        systm--observability-maintenance-log, flake.lib.maintenanceLoggerScript
├── maintenance-log/maintenance-logger.sh              the `maintenance-log` CLI
├── maintenance-log/_internals/checklist.nix           31 sections: code, name, hint
├── observability-backup/default.nix                   systm--observability-backup
├── ntfy/default.nix                                   servc--observability-ntfy
└── prometheus/
    ├── default.nix                                    servc--observability-prometheus, flake.lib.prometheusRendered, flake.lib.prometheusMaintenanceAlerts
    └── _internals/
        ├── options.nix                                all options (incl. maintenance.*)
        ├── config.nix                                 users, dirs, services, tsdb-guard, bridge to host-exporters
        ├── services/prometheus.nix                    the prometheus systemd unit + preStart
        ├── rendered.nix                               prometheusConfig + rules attrsets (shared with CI)
        ├── scrape-configs.nix                         base / maintenance / extra scrape jobs
        ├── maintenance-alerts.nix                     all alert + recording rules, feature-gated
        ├── exporters/maintenance.nix                  blackbox, systemd exporter, backup-status exporter
        └── extras/nginx.nix                           optional nginx vhost
sops/alertmanager.nix  (consumer supplies the file)    nsops--observability-alertmanager
sops/grafana.nix       (consumer supplies the file)    nsops--observability-grafana
flake/lib/obs-lib.nix                                  obsLib helpers (hardening, WAL self-heal, permissions, keyed…)
flake/ci/
├── observability-checks.nix                           build-time validation of rendered configs, rules, ports, runbooks
├── contract-checks.nix                                module-key (double import) contract
├── docs.nix                                           generated options reference + docs link check
├── vm-smoke.nix                                       NixOS VM test (packages.vm-smoke)
├── apps.nix                                           mon-check, mon-snapshot, mon-unitdiff (packages + apps)
├── host-checks.nix                                    lib.observabilityHostChecks (for consumers' CI)
├── _harness/default.nix                               fake machines used by the checks
├── _tests/prometheus/rules.test.yml                   promtool rule unit tests
└── _golden/domain-effects.json                        pinned side effects of setting `domain`
compat/                                                DEPRECATED names (options, modules) and their checks; removed in 0.4.0
bin/mon-check.sh | mon-snapshot.sh | mon-unitdiff.sh   runtime verification (sources of the packaged scripts)
.github/workflows/{ci,release,update-flake-lock}.yml  CI, releases, weekly lock updates
docs/                                                  README.md, architecture/ (public-api.md, decisions/), reference/options.md (generated),
                                                       operations/ (e.g. zfs-metrics.md), runbooks/, development/ (migration guides)
README.md  CHANGELOG.md
```

**Underscore convention.** Paths containing a `_`-prefixed segment (`_internals/`, `_tests/`, `_harness/`, `_golden/`) are *not* auto-imported by import-tree. They are plain files imported by relative path from their owner (`default.nix`) or referenced by CI. That is why `maintenance-alerts.nix` is both `import`ed by `rendered.nix` and registered as `flake.lib.prometheusMaintenanceAlerts` by `prometheus/default.nix`.

**`flake.lib` registrations** (consumed by name, never by path): for CI `grafanaDashboards` (the dashboards directory), `maintenanceLoggerScript`, `prometheusRendered` (function `{config, lib}` → `{rules, prometheusConfig}`), `lokiRendered` (function `{config, lib}` → the Loki config attrset), `alloyRendered` (function `{config, …}` → the full Alloy config text), `prometheusMaintenanceAlerts` (function → `{groups, core, maintenance, allGroups}`); for consumers `observabilityHostChecks`; internal `obsLib`.

---

## 5. The aggregator: `stack--observability`

`stacks/observability.nix`, exported as `stack--observability` and `default`. Imports the six service modules (`servc--observability-{alloy,loki,prometheus,ntfy,alertmanager,grafana}`) plus `systm--observability-maintenance-log` and `systm--observability-backup` (Prometheus itself imports `systm--observability-host-exporters`). The `nsops--observability-*` secrets modules are **not** imported (§9). While the deprecated names exist (until 0.4.0) it also imports `compat-options`, which maps the old option names onto the new ones.

### 5.1 Options: `services.observability`

| Option | Default | Meaning |
|---|---|---|
| `enable` | false | Turns on the whole stack |
| `listenAddress` | null | Force one bind address for *all* services (overrides per-service logic; loopback scrape jobs then may not reach them) |
| `publicHost` | `null` | Host/address used in UI links and notification links; builds each service's `externalUrl` when set |
| `access.interfaces` | `[]` | Interfaces on which `access.expose` ports are opened (policy: ADR-008). Empty → loopback only. Names must be non-empty |
| `access.expose` | `[grafana ntfy prometheus]` | Subset of `grafana ntfy alertmanager prometheus loki` |
| `probes.gateway` | `null` | Gateway address to ICMP-probe |
| `probes.icmpTargets` | `[]` | Addresses to ICMP-probe |
| `probes.tcpTargets` | `[]` | TCP targets to probe |
| `openFirewall` | false | Legacy: open each service port on all interfaces (with `domain` set: ports 80/443) |
| `dataDir` | `/data` | Root; each service uses `<dataDir>/<svc>` |
| `loki.retention` / `loki.maintenance.enable` | `744h` / false | Log retention; maintenance logging (Alloy pipeline + helper) |
| `prometheus.maintenance.enable` | **false** | **Loads all non-core alert groups, smartctl/blackbox exporters, textfile dir** |
| `prometheus.scrapeInterval` | `30s` | Scrape and evaluation interval |
| `prometheus.retention` / `.retentionSize` | `15d` / null | TSDB retention; size cap |
| `prometheus.maintenance.exporters.systemd` / `.smartctl.enable` | false / true | Separate systemd exporter (redundant with node's collector) / SMART exporter |
| `ntfy.cachePersist` | true | Persist ntfy cache to `<dataDir>/ntfy/cache.db` |
| `notifications.useNtfy` | true | Wire Alertmanager → ntfy; false means define your own receivers |
| `notifications.ntfyTopic` | `alerts` | Topic |
| `notifications.formatMessages` | true | ntfy templating (needs ntfy ≥ 2.10) |
| `notifications.ntfyAuth.enable` | false | ntfy auth, `alertmanager` (write-only) + `reader` (read-only) users; passwords come from `ntfyAuth.environmentFile` |
| `notifications.separateCritical` | true | Critical alerts get their own receiver (priority 5) |
| `notifications.topics.<name>` | none | Extra ntfy topics `<ntfyTopic>-<name>` with `matchers`, `priority`, `tags`, `alsoCatchAll` |
| `integrations.{traefik,cadvisor,postgres}.{enable,target}` | off; `127.0.0.1:8082/8080/9187` | Extra scrape job + feature-flag the matching alert groups |
| `integrations.nvidia.enable` | false | Load the `NvidiaXid` Loki-ruler alert (needs the NVIDIA kernel driver) |

### 5.2 Bind address and exposure logic

```
bindAddress(name) =
    listenAddress                                   if listenAddress != null
    "0.0.0.0"                                       if access.interfaces != [] && name ∈ access.expose
    "127.0.0.1"                                     otherwise
networking.firewall.interfaces.<iface>.allowedTCPPorts = [ port of each name ∈ access.expose ]   (for each iface in access.interfaces)
```
Ports 9094 (Alertmanager gossip) and Loki gRPC are never opened. Per-service `openFirewall` is set to `mkDefault cfg.openFirewall` (false), overriding each module's own default of `true`.

> **Security note.** Prometheus, Loki and Alertmanager have **no authentication**. Grafana has a login. ntfy is open to anyone who can reach it unless `notifications.ntfyAuth.enable = true`. Putting a service in `access.expose` and an interface in `access.interfaces` makes it reachable by everything on that network, so name only interfaces you trust, or use a reverse proxy (`domain`, §6) with authentication in front. The flake does not know which interface is wireless and does not filter names (ADR-008).

### 5.3 What the stack wires (the cross-service contract)

| Wiring | Where it lands |
|---|---|
| uids/gids (`mkDefault`) loki 740, alloy 741, grafana 742, prometheus 743, ntfy 744 | each module's `uid`/`gid` |
| `dataDir` = `<dataDir>/{grafana,loki,prometheus,ntfy}`; `listenAddress`; `openFirewall` | each module |
| `externalUrl` = `http://<publicHost>:<port>/` (ntfy without trailing slash) | grafana, alertmanager, prometheus, ntfy |
| Grafana `prometheusUrl` = Prometheus `externalUrl` or `http://localhost:9090` | dashboards' `prometheus_url` variable (browser-reachable link target) |
| Grafana datasources `Prometheus` (uid `prometheus`, default), `Loki` (uid `loki`), `Alertmanager` (uid `alertmanager`, `implementation=prometheus`, `handleGrafanaManagedAlerts=false`), all at `127.0.0.1` | `services.observability-grafana.provisioning.datasources` |
| Scrape jobs `ntfy`, `loki`, `grafana`, `alertmanager` (loopback), `alloy` (if enabled), plus traefik/cadvisor/postgres if enabled | `services.observability-prometheus.extraScrapeConfigs` |
| `alertmanagerTargets = [127.0.0.1:9093]` | Prometheus → Alertmanager |
| Alert feature flags `traefik`, `containers`, `postgres` | `maintenance.alerts.features` (`zfsMembers` is left to the consumer) |
| ICMP targets: `probes.gateway` + `probes.icmpTargets`; TCP targets: `probes.tcpTargets` | `maintenance.exporters.blackbox.{icmpTargets,tcpTargets}` |
| Receivers `null`, `ntfy`, (`ntfy-critical`); default receiver `ntfy` | Alertmanager |
| Route: `severity="critical"` → `ntfy-critical` (groupWait 10s, repeat 1h); everything else → `ntfy` | Alertmanager |
| Loki ruler enabled, `alertmanagerUrl=http://127.0.0.1:9093`, rule group `journal` (3 alerts, plus `NvidiaXid` when `integrations.nvidia.enable`) | Loki |
| Retention override `{job="<lokiJob>"}` kept 17520 h (2 years) | `services.observability-loki.retentionStreams` |
| Alloy `enable = mkDefault true`; `lokiUrl` local; maintenance pipeline appended to Alloy config when `loki.maintenance.enable`, labelled `job=<lokiJob>` | Alloy |
| `maintenance-log.enable` follows `loki.maintenance.enable`; its `textfileDir` is read from host-exporters' `nodeExporter.textfileDir` when Prometheus maintenance is on | helper |
| ntfy auth users + `ntfyAuth.environmentFile`; the restart wiring for a changed secret (`ntfy-provision`) lives in `nsops--observability-alertmanager` | ntfy (when `ntfyAuth.enable`) |
| Backup sources: sqlite `grafana.db`, ntfy `cache.db`, ntfy `user.db` (if auth); plain `/var/lib/private/<Alertmanager StateDirectory>` and the maintenance log; target `<dataDir>/backup` | `services.observability-backup` |

### 5.4 ntfy notification format

Alertmanager posts its webhook JSON to `http://127.0.0.1:2586/<topic>?...`. With `formatMessages`, ntfy renders it with a Go template (`tpl=1`):
- **Title:** `[<status>] <host>: <alertname>` — `host` is the *first alert's* `host` label (Prometheus external label, or the aggregation label on Loki-ruler alerts).
- **Message:** for each alert: summary, description, runbook URL (if present).
- **Priority/tags:** `ntfy` tags=`warning`; `ntfy-critical` p=5 tags=`rotating_light`.
- **Click:** opens Grafana (`click=` set when Grafana has an `externalUrl`).
- Basic auth to ntfy (`alertmanager` / `$NTFY_ALERTMANAGER_PASSWORD`) when `ntfyAuth.enable`.

---

## 6. Component reference

Conventions: **Unit** = systemd unit; **State** = on-disk state; **Hardening** = flags passed to `mkServiceHardening` (§11). Module files are under `modules/nixos/<service>/`.

### 6.1 Prometheus (`servc--observability-prometheus`)

**Files:** `prometheus/default.nix` (entry: imports `systm--observability-host-exporters`; wraps config in `mkIf enable (mkMerge [config.nix, mkWalSelfHeal])`), `prometheus/_internals/*`.

**Unit `prometheus`** (`services/prometheus.nix`): custom unit, user/group `prometheus`, `after network.target prometheus-permissions.service time-sync.target`, `wants time-sync.target`. Hardening: `extraHardening`, `writablePaths=[dataDir]`. `Restart=on-failure`, `RestartSec=10s`, `ExecReload` = SIGHUP.
`preStart` (runs as `prometheus`): renders `prometheus.yml` (mode 660) and `rules/alerts.yml` (mode 644) from JSON via `remarshal`, `mkdir data`.
`ExecStart`: `--config.file=<dataDir>/prometheus.yml --storage.tsdb.path=<dataDir>/data --storage.tsdb.retention.time=<retention>[ --storage.tsdb.retention.size=…] --web.listen-address=<addr>:<port>[ --web.external-url=…]`.

**Users:** `prometheus` (system user, `uid/gid` from options, extra group `disk` if smartctl is on) and every `extraUsers` entry is added to group `prometheus` (read access to data).

**Rendered config** (`rendered.nix`, also used by CI):
- `global`: `scrape_interval`, `evaluation_interval` (module defaults 15s; stack sets 30s), `external_labels = {monitor="prometheus", host=<hostname>}`. The `host` external label is attached to every alert sent to Alertmanager and is what notifications show.
- `alerting.alertmanagers`: one static config when `alertmanagerTargets != []`.
- `rule_files: ["<dataDir>/rules/*.yml"]`.
- `scrape_configs` (see below).
- Rules: `core` groups ++ (if `maintenance.enable`) `maintenance` groups. Rendered with `runbookBase` taken from option `runbookBaseUrl` and the `condition` label on.

**Scrape jobs** (`scrape-configs.nix`)

| Job | Target | Condition | Notes |
|---|---|---|---|
| `prometheus` | `localhost:<port>` | always | |
| `node` | `localhost:9100` | `enableNodeExporter` | labels `instance="localhost"`, `alias=<hostname>` |
| `systemd` | `localhost:9558` | maintenance + `exporters.systemd` | off by default |
| `smartctl` | `localhost:9633` | maintenance + `smartctl.enable` | `slowScrapeInterval` (60s) |
| `blackbox-http` / `-icmp` / `-ssl` / `-dns` / `-tcp` / `-http-insecure` | per target list | maintenance + blackbox enabled + non-empty list | blackbox pattern: `__address__`→`__param_target`→`instance`, address rewritten to `localhost:9115`, modules `http_2xx`, `icmp`, `http_2xx` (ssl), `dns_a`, `tcp_connect`, `http_2xx_insecure` |
| extras | — | from `extraScrapeConfigs` | stack: ntfy, loki, grafana, alertmanager, alloy, integrations |

**Exporters** (`exporters/maintenance.nix`): upstream `services.prometheus.exporters.systemd` and `.blackbox` (listen `127.0.0.1` via `mkDefault`; blackbox modules file written to the store: `http_2xx`, `http_2xx_insecure`, `dns_a` using `dnsQueryName`, `icmp`, `tcp_connect`, all `preferred_ip_protocol: ip4`, 5s timeouts). Optional `backup-status-exporter` unit (loop every 300s reading a timestamp file and a size file and writing `<textfileDir>/backup_metrics.prom`: `backup_job_last_success_timestamp`, `backup_job_size_bytes`, label `job_name`). Off by default.

**Bridge to host-exporters:** `config.nix` sets `services.observability-host-exporters.{nodeExporter.enable, nodeExporter.textfileDir, smartctl.enable/port/devices}` from Prometheus options. `nodeExporter.textfileDir` (`/var/lib/node_exporter`, set when maintenance is on) is the **single source** of the textfile directory: the tmpfiles rule, the backup-status exporter and the maintenance-log module read it rather than repeating the path. The other values use `mkDefault` so a host can override.

**Other units** (`config.nix`): `prometheus-permissions` (§11), `prometheus-tsdb-guard` + timer (§12), and `prometheus-wal-recover` (via `mkWalSelfHeal`, `walDir=<dataDir>/data/wal`).

**Options** (`services.observability-prometheus`): `enable`, `port` (9090), `listenAddress` (127.0.0.1), `domain`, `externalUrl`, `enableSSL`, `dataDir` (default `/var/lib/prometheus2`; stack: `/data/prometheus`), `retention` (15d), `retentionSize`, `scrapeInterval`, `evaluationInterval`, `slowScrapeInterval`, `package`, `openFirewall`, `blackboxPort`, `smartctlPort`, `systemdExporterPort`, `enableNodeExporter`, `uid`, `gid`, `extraScrapeConfigs`, `alertmanagerTargets`, `extraUsers`, `runbookBaseUrl`, and `maintenance.{enable, expectedMounts, alerts.features.{traefik,containers,postgres,zfsMembers}, exporters.{systemd, blackbox.{enable,httpTargets,icmpTargets,sslTargets,dnsTargets,tcpTargets,httpInsecureTargets,dnsQueryName}, smartctl.{enable,devices}, backup.{enable,timestampFile,sizeFile,jobName}}}`.

**Derived alert feature flags** (`rendered.nix`): `backup` = backup exporter enabled; `dns` = blackbox on and `dnsTargets != []`; `blackboxProbes` = blackbox on and any of http/icmp/ssl/tcp/http-insecure targets non-empty; `alertmanagerWired` = `alertmanagerTargets != []`; plus the user flags `traefik`, `containers`, `postgres`, `zfsMembers` (all default `false`).

### 6.2 Host exporters (`systm--observability-host-exporters`)

Node and smartctl exporters live in their own module so they can run without Prometheus. Options: `services.observability-host-exporters.{user, nodeExporter.{enable,port,listenAddress,textfileDir}, smartctl.{enable,port,listenAddress,devices}}` (there is no single top-level `enable`).

- **Node exporter** (`prometheus-node-exporter`, custom unit, runs as `cfg.user`, default `prometheus`; the user/group are `mkDefault`ed here so Prometheus' own definition wins when it is enabled). Listen `localhost:9100` by default. Collectors enabled: `pressure`, `processes`, `systemd` (+ restart metrics; only `.service`/`.timer` units), `hwmon`, `netclass`, `netdev`, and `textfile` when `textfileDir` is set. Filesystem collector excludes mountpoints `/dev|/proc|/run|/sys` and fs types incl. `nfs`, `nfs4`, `overlay`, `squashfs`, `tmpfs`-like pseudo types (NFS client mounts are not checked). ZFS metrics (`node_zfs_*`, `node_zfs_zpool_state`) come from node_exporter's default zfs collector.
  Hardening: `extraHardening` but with `SystemCallFilter=""`, `ProtectClock=false` (the timex collector needs `adjtimex`; otherwise `ClockDrift` goes silent), `ProtectProc=default`, `ProcSubset=all`, `RestrictAddressFamilies` incl. `AF_NETLINK`, `MemoryMax=256M`, `TasksMax=128`.
- **smartctl exporter**: upstream module on `127.0.0.1:9633`; the unit is given `CAP_SYS_RAWIO` (ambient + bounding), `DeviceAllow` for `/dev/sd*` and `/dev/nvme*` (read), `PrivateDevices=false`. `devices=[]` means scan.

### 6.3 Alertmanager (`servc--observability-alertmanager`)

Delegates to upstream `services.prometheus.alertmanager` (DynamicUser, state under `/var/lib/private/alertmanager`, amtool config check, envsubst of `$VAR`). The module assembles `configuration` from typed options and deep-merges `extraConfig` over it (`recursiveUpdate`; lists such as `receivers` are replaced, not merged).

- **Config shape:** `global.resolve_timeout` (5m) + optional SMTP/Slack/PagerDuty globals; root `route` (`receiver=defaultReceiver`, `group_by=[alertname instance]`, `group_wait 30s`, `group_interval 5m`, `repeat_interval 4h`) with child `routes`; `receivers`; `inhibit_rules`; `time_intervals`.
- **Default inhibit rules:**
  1. `severity=critical` suppresses `severity=warning` when `instance` and `category` are equal. (Consequence: a critical on one mountpoint suppresses warnings for other mountpoints on that host; the suppressed alerts stay visible in Alertmanager as "inhibited".)
  2. `alertname=PrometheusNoRecentSamples` suppresses `category=observability` alerts (except itself) for the same `instance` — when Prometheus can't store samples, its other self-reports are unreliable.
- **Secrets:** `environmentFile` (set by `nsops--observability-alertmanager`, or by you) is passed to the upstream module; `$VAR` references in receivers are expanded at start. `checkConfig` defaults to `environmentFile == null` (build-time `amtool` can't see secrets); an assertion forbids env file + `checkConfig=true`.
- **Clustering:** with no `clusterPeers`, `--cluster.listen-address=` (empty) disables the gossip listener (previously `*:9094`). With peers, it listens on `clusterPort` and an assertion requires `openFirewall`.
- **`webExternalUrl`:** `domain` → `externalUrl` → `http://<listen>:<port>/`. The upstream module appends the port to `listenAddress`; never include it.
- **Assertions:** SSL needs domain; every route/default receiver name must exist in `receivers`; env-file/checkConfig; cluster peers need firewall.
- **Options:** `enable, port, listenAddress, domain, externalUrl, enableSSL, package, openFirewall, checkConfig, environmentFile, clusterPeers, clusterPort, global.*, defaultReceiver, route.{groupBy,groupWait,groupInterval,repeatInterval,routes}, receivers, inhibitRules, timeIntervals, extraConfig` (and `secretsFile` from the sops module). Route submodule: `receiver, matchers, groupBy, groupWait, groupInterval, repeatInterval, continue, muteTimeIntervals`.

### 6.4 ntfy (`servc--observability-ntfy`)

Custom unit `ntfy` (user/group `ntfy`, `extraHardening`). `preStart` renders `server.yml` (mode 640) from an attrset.

- **Generated config:** `base-url` (domain → `externalUrl` → listen address), `listen-http`, `cache-duration` (12h), `cache-file` if set, topic/visitor limits, `enable-signup=false`, `enable-login`/`enable-reservations` = `auth.enable`, `enable-metrics=true`, `behind-proxy` = domain set, attachment settings (opt.), `auth-file=<dataDir>/user.db` + `auth-default-access` when auth is on, SMTP-to-ntfy bridge (opt.), `upstream-base-url` (opt.), `web-root=disable` if `enableWebUI=false`.
- **Auth provisioning** (`ntfy-provision`, oneshot, `RemainAfterExit`): waits (≤30s) for `/v1/health`, then for each user in `auth.users`: `ntfy user add --ignore-exists --role=…`, `ntfy user change-pass`, `ntfy access <user> <topic> <perm>`. Passwords come from `auth.environmentFile` via variable names (`passwordEnvVar`); the CLI reads `NTFY_PASSWORD`. Idempotent. Stack users: `alertmanager` (write-only on topic) and `reader` (read-only).
- **Assertions:** SSL needs domain; `auth.users` needs `auth.enable` and an env file; SMTP needs a domain; attachments need `cacheFile`.
- **Firebase** key via `Environment=NTFY_FIREBASE_KEY_FILE=…` (opt.).

### 6.5 Loki (`servc--observability-loki`)

Custom unit `loki` (user/group `loki`, `extraHardening`, `TimeoutStopSec=5min` so WAL flush on stop isn't killed). The config attrset lives in `loki/_internals/rendered.nix` (exposed to CI as `flake.lib.lokiRendered`) and is rendered in `preStart` to `<dataDir>/loki.yaml`.

- **Generated config:** single-binary, `auth_enabled=false`, in-memory ring, replication 1; HTTP on `listenAddress:port`; **gRPC bound to `127.0.0.1:9096`**; filesystem chunk store; TSDB index schema `v13` from 2023-01-01 (period 24h); WAL enabled at `<dataDir>/wal`, `flush_on_shutdown`; compactor with retention enabled (delete delay 2h); 100 MB embedded results cache.
- **Limits:** retention `retention` (default 744h = 31d); per-stream overrides from the `retentionStreams` option (`selector`, `period`, `priority`), **empty by default**; the stack sets one for `{job="<lokiJob>"}` (the maintenance log) kept 17520h (2 years). Ingestion 4 MB/s (burst 8), per-stream 3 MB/s (burst 10); `reject_old_samples` older than 168h; `max_entries_limit_per_query` 5000; `max_query_series` 10000.
- **Ruler** (opt.): local rule storage `<dataDir>/rules/fake/journal.yaml` (`fake` is the tenant name when auth is off), `alertmanager_url`, API enabled. Rule groups come from `ruler.groups` (set by the stack).
- **Self-heal:** `mkWalSelfHeal` on `<dataDir>/wal`. `loki-permissions` oneshot re-chowns the data dir at boot.
- **Removed options:** `enableAlloy`, `alloyPackage`, `alloyPort` and `maintenance.*` were removed from Loki in 0.2 (no alias); the stack configures Alloy and the maintenance log itself. Other options: `grpcPort`, `openGrpcFirewall` (default false; multi-instance only).
- **Validation:** the `loki-config` check renders the config for the `stable` test host and runs `loki -verify-config`.
- **Assertions:** SSL needs domain; ruler needs `alertmanagerUrl`.

### 6.6 Alloy (`servc--observability-alloy`)

Custom unit `alloy` (user/group `alloy`, member of `systemd-journal`; `allowJIT`, `extraHardening`, with `/proc` fully visible). Runs `alloy run --disable-reporting --server.http.listen-addr=127.0.0.1:<port> --storage.path=/var/lib/alloy/data /var/lib/alloy/config.alloy`. `preStart` installs the generated config. The base pipeline text is in `alloy/_internals/rendered.nix`; `flake.lib.alloyRendered` returns base plus `extraConfig` for CI (`alloy-config` check: `alloy fmt`).

- **Base pipelines** (host label = hostname):
  - `loki.write "local"` → `lokiUrl`.
  - Journal: `loki.source.journal "systemd"` (`max_age 12h`), relabel `__journal__systemd_unit`→`unit`, `__journal_priority_keyword`→`level`, `__journal__transport`→`transport`; processed with static labels `job=systemd-journal`, `host`, keeping only `job host unit level transport`.
  - Files: `/var/log/*.log` → `job=varlogs`, `host`.
- **Appended `extraConfig`:** the stack adds the maintenance pipeline when `loki.maintenance.enable`: tail the maintenance log path, parse JSON, labels `section status user`, static `job=<lokiJob>` (default `maintenance-log`) and `host=<hostname>`, timestamp from the entry's `timestamp` (RFC3339).
- **Ordering:** after `network.target`, local `loki.service` (if `afterLocalLoki`, default true), `alloy-permissions.service`, `time-sync.target`.
- `lokiUrl` can point at a Loki elsewhere; set `afterLocalLoki=false` if no Loki runs on the host.
- `extraUsers` adds users to the `alloy` group.

### 6.7 Grafana (`servc--observability-grafana`)

Custom unit `grafana` (user/group `grafana`, `extraHardening`, `UMask=0027`). Configured entirely by `GF_*` environment variables (paths under `<dataDir>`: `data`, `logs`, `plugins`, `provisioning`, `dashboards`; sqlite DB `data/grafana.db`; analytics, sign-up, Gravatar, news feed all off; anonymous access off unless `allowAnonymous`).

- **Secrets:** `GF_SECURITY_ADMIN_PASSWORD__FILE` / `GF_SECURITY_SECRET_KEY__FILE` from `credentialsFile` / `secretKeyFile` (plain strings, never `path`, so nothing enters the store). A warning is emitted if `secretKeyFile` is null. The admin password applies only on first DB creation; afterwards use `grafana cli admin reset-admin-password`. Changing the secret key on an existing DB makes stored secrets unreadable.
- **`ExecStartPre` step 1 (root, `+` prefix):** removes dashboard dirs and provisioning YAMLs that are no longer declared; backs up `grafana.db` once per day (`grafana.db.pre-cleanup-<date>`); deletes from the sqlite DB any *provisioned* dashboard that is no longer declared or whose uid no longer matches the JSON file (so renamed/re-uid'd dashboards re-provision cleanly), and empty folders; creates the provisioning/dashboard directories.
- **Step 2 (grafana user):** writes `provisioning/datasources/datasources.yaml` (from `provisioning.datasources`, type lower-cased); for each dashboard, copies the JSON to `dashboards/<name>/dashboard.json` via `jq`, rewriting the `prometheus_url` template variable to `prometheusUrl` and the `timers_regex` variable to `timersRegex`; writes a file-provider YAML (`folder`, `updateIntervalSeconds`, `allowUiUpdates`).
- **Dashboards:** `dashboards` (default: only `system-overview-v5` → `system-overview-v5.json`; a `maintenance` entry is commented out in the module and `maintenance-checklist.json` is not in the repo), plus `extraDashboards` (list of names resolving to `dashboards/<name>.json`, folder `maintenance`). Assertions: all named files exist; no name clashes with built-ins. After adding a JSON file, `git add` it.
- **`timersRegex`** (default `nixos-upgrade.timer|nix-gc.timer`): regular expression of the systemd timers shown in the "Time since each timer last fired" panel. Set it to the timers you care about.

| Dashboard | uid | Contents |
|---|---|---|
| `system-overview-v5.json` | `system-maintenance-overview-v5` | Health score, alerts by severity, failed units, hottest sensor, uptime, kernel, root FS, RAM, swap; firing/pending alert table with `condition` and Prometheus deep-link; firing by category/section; CPU, memory, pressure, disk, inode, IO, time-to-full, network, hwmon temperatures, CPU frequency, clock offset, failed units; service uptime; alert timeline; collapsed rows: **Observability Stack Health**, **Containers**, **Web & Network Probes**, **Backups & Certificates**, **Maintenance Checklists**; Extended metrics; Drive health (SMART, temperature, NVMe wear); Timers (filtered by `timersRegex`); Logs (Loki: journal errors by unit, failed SSH logins, kernel warnings); Maintenance (days since last completed, failed/skipped entries, recent entries; these two Loki panels query the default `job="maintenance-log"` label) |
| `zfs-monitoring.json` (opt-in: `extraDashboards=["zfs-monitoring"]`) | `zfs-pool-monitoring` | Pool state, member disks and integrity, dataset I/O, ARC, ZIL, dataset space; `$zpool` variable. Its member-disk and scrub panels need the textfile metrics in `docs/operations/zfs-metrics.md` |

Dashboards use the hidden datasource variable `DS_PROMETHEUS` (resolves to the default Prometheus datasource) and the fixed Loki uid `loki`. Dashboard-only metrics that need other exporters (containers, traefik, backups) show "no … metrics" placeholders until enabled.

### 6.8 Maintenance log (`systm--observability-maintenance-log`)

- **Checklist** (`_internals/checklist.nix`): 31 entries `{code, name, hint}` — I.1–I.3 hardware, II.4–II.6 OS, III.7–III.9 storage/backup, IV.10–IV.13 network/security, V.14–V.17 services, VI.18–VI.20 containers/VMs, VII.21–VII.23 observability itself, VIII.24–VIII.26 config/docs, IX.27–IX.28 redundancy/DR, X.29–X.31 weekly/monthly/quarterly. There is no cadence or overdue tracking. This list is also the source of truth for the `checklist_section` labels used on alerts.
- **CLI** `maintenance-log` (wrapper over `maintenance-logger.sh`, with `jq coreutils gawk gnugrep` on PATH, `MAINTENANCE_LOG`, `MAINTENANCE_CHECKLIST` set). Interactive menu or flags:
  ```
  maintenance-log --section X.30 --task "Applied updates" [--status completed|skipped|failed] [--notes "…"] [--when "3 days ago"]
  maintenance-log --list-sections | --help
  ```
  `QUICK` is a valid free-form section. Entries are JSON lines `{timestamp(UTC), level, section, task, status, notes, hostname, user}`; under `sudo`, `user` is the invoking user.
- **File:** `/var/log/maintenance.jsonl` (never `.log`), mode 0664 `root:wheel` (wheel-writable only, to prevent forged audit entries), logrotate monthly, 24 kept, `copytruncate`.
- **Options:** `enable`, `logPath`, `textfileDir`, and `lokiJob` (default `maintenance-log`): the Loki `job` label of this log, which the stack uses for both Alloy's label and Loki's retention stream.
- **Metrics** (only if `textfileDir` set): timer every 5 min (+1 min after boot) runs `maintenance-log-metrics`, which reads the current file and `.1`, finds the latest `completed` timestamp per section, and writes `<textfileDir>/maintenance.prom` with `maintenance_last_completed_timestamp_seconds{section}` for **every** section (0 = never). The dashboard panel *Days since last completed, by section* uses it; there is no alert.

### 6.9 Backup (`systm--observability-backup`)

Daily at 03:15 (+≤15 min, `Persistent`), `observability-backup` oneshot (root, `UMask 0077`): for each SQLite file, `sqlite3 <f> ".backup '<dir>/<basename>.bak'"` (consistent online copy); for each plain path, `cp -a` into `<dir>`. The stack points `dir` at `<dataDir>/backup`; **that directory must be included in your normal off-host backup**. Prometheus TSDB and Loki chunks are *not* backed up.

---

## 7. Alerting reference

### 7.1 Pipeline

1. Prometheus evaluates rule groups (each group has its own `interval`, 30s–5m).
2. Deployed rules get (a) a `condition` label = the whitespace-squashed expr plus ` (for <dur>)`, so a firing alert shows *why* directly from the `ALERTS` series, and (b) a `runbook` annotation = `<runbookBaseUrl>/<alert>.md`. Neither is applied in unit tests/CI rule files (`conditionLabel=false`, `runbookBase=null`).
3. Firing alerts go to Alertmanager (`alertmanagerTargets`), carrying the `host` external label.
4. Alertmanager groups by `alertname, instance`, applies inhibition (§6.3), picks a route: critical → `ntfy-critical`; everything else (warnings) → `ntfy`.
5. The receiver webhooks ntfy; ntfy templates it (§5.4).
6. Loki-ruler alerts skip Prometheus and go straight Loki → Alertmanager.

### 7.2 Label conventions

| Label | Values | Use |
|---|---|---|
| `severity` | `warning`, `critical` | Routing, inhibition, health score (critical −20, warning −5, floor 0) |
| `category` | `hardware storage os network security service web database container backup observability` | Inhibition (`equal`), dashboards |
| `checklist_section` | e.g. `I.1`, `VII.21` | Maps to the maintenance checklist; dashboard tables filter on it |
| `condition` | generated | Why it fired |

Alert names and these labels are part of the public contract (`public-api.md`); expressions and thresholds are not.

### 7.3 Feature gating

Rules may carry `requires = "<flag>"`; they load only when the flag is true (and the attribute is stripped). Flags: `traefik`, `containers`, `postgres`, `backup`, `dns`, `blackboxProbes`, `alertmanagerWired`, `zfsMembers`. Groups marked `core = true` load even when `maintenance.enable=false`: `observability_stack`, `stack_self_health`, `maintenance_metrics`. `ExpectedMountMissing` is generated once per entry in `maintenance.expectedMounts` (host option, not exposed by the stack). The user-set flags are options under `services.observability-prometheus.maintenance.alerts.features.*` (all default `false`); the stack turns on `traefik`, `containers` and `postgres` from `integrations.*`; `zfsMembers` is for the consumer to set, together with the textfile metrics in `docs/operations/zfs-metrics.md`.

### 7.4 Alert catalogue (Prometheus)

Section = `checklist_section`. **W** warning, **C** critical. "for" is the pending time.

**hardware_health (30s)**
| Alert | Sev | Condition (summary) | for |
|---|---|---|---|
| HighCPUTemperature | W | coretemp/k10temp/amdgpu hwmon >80 and ≤90 °C (I.1) | 5m |
| CriticalCPUTemperature | C | same sensors >90 °C | 2m |
| NVMeHighTemperature | W | `nvme` hwmon >75 and ≤85 °C | 10m |
| NVMeCriticalTemperature | C | `nvme` >85 °C | 5m |
| CPUThrottling | W | cores below 60% of max freq while >50% busy, not on battery (aggregated per host) | 10m |
| FanSpeedLow | W | fan <1000 rpm that was >1500 in 7d, while host >55 °C | 5m |
| LowDiskSpace | W | 10–20% free (I.2) | 5m |
| CriticalDiskSpace | C | <10% free | 2m |
| DiskWillFillIn24h | W | `predict_linear` 6h → <0 in 24h and <50% free | 1h |
| HighInodeUsage | W | <20% inodes free | 5m |
| NetworkInterfaceErrors | W | >10 errs/s (I.3) | 5m |
| NetworkPacketDrops | W | >50 drops/s | 5m |

Filesystem filter excludes `tmpfs overlay squashfs ramfs devtmpfs nsfs erofs fusectl fuse.* zfs` and `/nix/store`, `/run/*`; network filter excludes `lo veth docker br- virbr`.

**os_health (1m)** — OutOfMemoryKills (C, no `for`, II.5), ClockDrift (W, |offset|>0.1 s, 10m), ClockNotSynced (W, `node_timex_sync_status==0`, 15m), HighCPULoad (W, load5/core >1.5, 30m, II.6), HighMemoryUsage (W, >85%, 5m), SwapUsage (W, >50%, 5m), HighIOWait (W, avg iowait >30%, 10m).

**storage_backups (5m)** *(all gated `backup`)* — BackupJobFailed (C, age >24h, for 1h, III.7), BackupSizeAnomaly (W, ±30% vs 7d ago), BackupMetricsMissing (W, `absent(...)`).

**network_security (1m)** — DNSResolutionFailure (C, gated `dns`, 3m, IV.12), HighNetworkLatency (W, ICMP >100 ms, 5m), CertificateExpiringSoon (W, 7–30 d, 1h, IV.13), CertificateExpiringCritical (C, <7 d, 1h).

**service_health (30s)** — HostDown (W, own node exporter down while Prometheus is up, 5m, V.14), ServiceDown (C, `up{job!~"prometheus|node"}==0`, 2m), SystemdServiceFailed (W, 5m), PostgresReplicationLag (W, gated `postgres`, V.15), HighHTTPErrorRate (W, gated `traefik`, 5xx ratio >5% and >0.05 req/s, 5m, V.16).

**container_health (30s)** *(gated `containers`)* — ContainerRestartLoop (W, >2 start-time changes in 15m, VI.18), ContainerHighMemory (W, >90% of a non-zero limit).

**probes (1m)** *(gated `blackboxProbes`)* — ProbeFailed (W, http/http-insecure/icmp/tcp probe_success==0, 5m, IV.12), SSLProbeFailed (W, 10m, IV.13).

**observability_stack (core, 1m)** — PrometheusNoRecentSamples (C, `absent_over_time(up{job="prometheus"}[10m])`, 5m, VII.21), PrometheusSamplesOutOfBounds (C, 10m), PrometheusHeadInFuture (C, head >1h ahead, 5m), PrometheusRuleEvaluationFailures (W, VII.22).

**stack_self_health (core, 1m)** — PrometheusConfigReloadFailed (C, 5m, VII.21), PrometheusNoAlertmanager (C, gated `alertmanagerWired`, 10m, VII.22), PrometheusNotificationsFailing (C, 10m), AlertmanagerNotifyFailing (C, 10m), PrometheusWALCorruption (W, no `for`), PrometheusCompactionFailing (W), LokiDiscardingSamples (W, 10m, VII.23), AlloyDroppingEntries (W, 10m).

**smart_health (5m)** — SMARTStatusFailed (C, I.1), SMARTErrorLogGrowing (W), SMARTSectorsGrowing (W; Reallocated/Pending/Offline_Uncorrectable growth in 7d), NVMeWearHigh (W, >80%), NVMeCriticalWarning (C), NVMeMediaErrors (W), NVMeSpareLow (C), SCSIDefectsGrowing (W, SAS grown defect list), SCSIUncorrectedErrors (W). The SCSI pair exists because SAS drives expose `smartctl_scsi_*` instead of ATA attributes.

**filesystem_integrity (1m)** — FilesystemReadOnly (C, 2m), FilesystemDeviceError (W, 5m), ExpectedMountMissing (C, 5m, one per expected mount).

**zfs_health (1m)** — the first two use node_exporter's own ZFS collector and are always loaded with maintenance alerts; the six **gated `zfsMembers`** need textfile metrics that node_exporter does not produce (see `docs/operations/zfs-metrics.md` for the metric names, labels and who must write them):

| Alert | Sev | Condition (summary) | for | Gate |
|---|---|---|---|---|
| ZpoolNotOnline | C | `node_zfs_zpool_state{state!="online"} == 1` (III.8) | 2m | — |
| ZpoolLowFree | W | <15% free on a ZFS pool's datasets | 15m | — |
| ZpoolDeviceErrors | W | `zfs_vdev_errors > 0` (read/write/checksum on a vdev) | 2m | `zfsMembers` |
| ZpoolDataErrors | C | `zfs_pool_error_count > 0` (permanent data errors) | 1m | `zfsMembers` |
| ZpoolScrubOverdue | W | no completed scrub in more than 10 days | 1h | `zfsMembers` |
| ZpoolScrubErrors | W | `zfs_last_scrub_errors > 0` (until the next clean scrub) | 5m | `zfsMembers` |
| ZpoolMemberMissing | C | `zfs_expected_device_present == 0` (by-id path gone) | 1m | `zfsMembers` |
| ZpoolMemberReonlined | W | a disk was automatically re-onlined within the last hour | — | `zfsMembers` |

An absent metric never alerts: with `zfsMembers` on but no producer writing the metrics, the six alerts are silent.

**battery_health (5m)** — BatteryHealthDegraded (W, <60% of design capacity, 1h; supports `energy_*` and `charge_*` metrics).

**Recording rules** (`maintenance_metrics`, core): `system:health_score:percentage`, `system:alerts_by_category:count`, `system:alerts_by_section:count`, `node:disk_usage:percentage`, `node:memory_usage:percentage`, `node:cpu_usage:percentage`. They read `ALERTS`, so they only reflect Prometheus-evaluated alerts.

### 7.5 Loki-ruler alerts (defined in the stack, group `journal`, 1m)

| Alert | Sev | LogQL (kernel/journal, 5m window unless noted) | Section | Gate |
|---|---|---|---|---|
| JournalOOMKill | C | kernel "out of memory: kill\|oom-kill" | II.5 | — |
| KernelFilesystemError | C | EXT4/XFS/BTRFS errors, "Remounting … read-only", "I/O error, dev" | III.8 | — |
| NvidiaXid | W | kernel `NVRM: Xid` | I.1 | `integrations.nvidia.enable` |
| SSHAuthFailureBurst | W | sshd failures >20 in 10m | IV.10 | — |

They set `instance={{ $labels.host }}`, `severity`, `category`, `checklist_section` so routing and inhibition work. They **do not exist as `ALERTS` series**: not in dashboard alert tables, the health score, or the promtool tests. Their runbooks are checked by `loki-runbook-coverage`.

### 7.6 Runbooks

`docs/runbooks/<AlertName>.md` using `_template.md` (What it means / Likely causes / First three commands / Fix / Escalate when / Related). `_todo.txt` lists alert names whose runbook is still to be written (empty today); delete a line when you write the page. The `runbook-coverage` check (Prometheus alerts) and `loki-runbook-coverage` check (Loki-ruler alerts) fail if an alert has neither.

---

## 8. Data flows

| Flow | Path |
|---|---|
| **Host metrics** | node_exporter `:9100` + textfile dir (`maintenance.prom`, `backup_metrics.prom`, optionally ZFS `*.prom`) → Prometheus job `node` |
| **SMART** | smartctl_exporter `:9633` → job `smartctl` (60s) |
| **Probes** | Prometheus → blackbox `:9115` `/probe?module=…&target=…` → jobs `blackbox-*` |
| **Stack self-metrics** | Prometheus scrapes its own `/metrics`, plus ntfy, loki, grafana, alertmanager, alloy |
| **Logs** | journald / `/var/log/*.log` / maintenance JSONL → Alloy → Loki push API (`/loki/api/v1/push`) |
| **Metric alerts** | Prometheus rules → Alertmanager `/api/v2/alerts` → webhook → ntfy |
| **Log alerts** | Loki ruler → Alertmanager → webhook → ntfy |
| **Manual maintenance** | `maintenance-log` → `/var/log/maintenance.jsonl` → (a) Alloy → Loki (2y) and (b) timer → `maintenance.prom` → node_exporter → Prometheus |
| **Visualisation** | Grafana → Prometheus / Loki / Alertmanager datasources (loopback) |
| **State protection** | `observability-backup` → `<dataDir>/backup` → your normal backup |

---

## 9. Secrets

sops-nix, age-encrypted, **optional** (ADR-009): the stack does not import the `nsops--observability-*` modules and the repository ships no encrypted material. A consumer either imports them and sets `secretsFile`, or sets the credential and `environmentFile` options to any file paths its own secret manager provides.

| Secret | File (supplied by the consumer) | Format | Consumer | Notes |
|---|---|---|---|---|
| `ALERTMANAGER_ENV` | the file named by `services.observability-alertmanager.secretsFile` | **dotenv** | Alertmanager (`EnvironmentFile`, read by systemd as root; owner left root because of DynamicUser); `ntfy-provision` (same file) | Keys used by the stack: `NTFY_ALERTMANAGER_PASSWORD`, `NTFY_READER_PASSWORD`. Other `$VAR`s for Slack/PagerDuty/SMTP are supported. `restartUnits=alertmanager.service` (plus `ntfy-provision.service` when ntfy auth is on) |
| `GRAFANA_ADMIN_PASSWORD`, `GRAFANA_SECRET_KEY` | the file named by `services.observability-grafana.secretsFile` | yaml | Grafana via `__FILE` variables | owner/group = Grafana user/group; `restartUnits=grafana.service`; wired with `mkDefault` |

`secretsFile` has no default; the consumer owns the encrypted values, the age recipients and the key location. The `reader` password is what `mon-check` needs as `MON_NTFY_AUTH=reader:<pw>`. `sops.age.keyFile` is the consumer's global setting, not set here. Without the sops modules set `services.observability-alertmanager.environmentFile`, `services.observability-grafana.{credentialsFile,secretKeyFile}` and `services.observability.notifications.ntfyAuth.environmentFile` directly.

---

## 10. Runtime layout (what is where on a host)

`<D>` = `services.observability.dataDir` (default `/data`).

| Path | Owner | Contents |
|---|---|---|
| `<D>/prometheus/prometheus.yml` | prometheus | generated config |
| `<D>/prometheus/rules/alerts.yml` | prometheus | generated rules |
| `<D>/prometheus/data/{wal,chunks_head,…}` | prometheus | TSDB; quarantines `wal.broken-*`, `chunks_head.broken-*` |
| `<D>/loki/loki.yaml` | loki | generated config |
| `<D>/loki/{chunks,wal,compactor,rules/fake/journal.yaml,rules-tmp}` | loki | store, WAL (quarantines `wal.broken-*`), ruler |
| `<D>/grafana/{data/grafana.db,logs,plugins,dashboards/<name>/dashboard.json,provisioning/…}` | grafana | state + provisioned content |
| `<D>/ntfy/{server.yml,user.db,cache.db,attachments/}` | ntfy | generated config, auth DB, message cache |
| `<D>/backup/*.bak` etc. | root | nightly copies |
| `/var/lib/alloy/{config.alloy,data/}` | alloy | generated config, positions |
| `/var/lib/private/alertmanager` | DynamicUser | silences, notification log |
| `/var/lib/node_exporter/*.prom` | prometheus | textfile metrics |
| `/var/log/maintenance.jsonl[.1…]` | root:wheel | maintenance records |
| `/var/lib/prometheus-tsdb-guard/last`, `/var/lib/<unit>-wal-recover/last-recovery` | root | cooldown stamps |

| Service | Port | Binds (default) | uid/gid pinned (stack) |
|---|---|---|---|
| ntfy | 2586 | loopback | 744 |
| Loki HTTP / gRPC | 3100 / 9096 | loopback / loopback | 740 |
| Grafana | 3101 | loopback | 742 |
| Prometheus | 9090 | loopback | 743 |
| Alertmanager | 9093 (9094 off) | loopback | DynamicUser |
| node / smartctl / blackbox / systemd exp. | 9100 / 9633 / 9115 / 9558 | loopback | prometheus / exporter users |
| Alloy | 12345 | loopback | 741 |

Pinned uids differ from the dynamically allocated ones on existing hosts. The `*-permissions` oneshots re-chown data dirs on boot; plan a reboot when changing uids.

---

## 11. Shared helpers (`obsLib`)

From `flake/lib/obs-lib.nix`, exposed as `self.lib.obsLib` (ADR-006). Internal: no stability promise before 1.0.

**`keyed key module`** — wraps a module as `{ inherit key; imports = [module]; }`. Every public module is defined as `self.lib.obsLib.keyed "observability:<name>" (…)`. NixOS de-duplicates modules by `key`, so importing a module alone, together with others, or through the stack applies it once and never declares an option twice (the `double-import` check pins this). A new module must use it too.

**`mkServiceHardening { writablePaths, allowNetwork, allowUnixSockets, allowDevices, allowJIT, extraHardening }`** returns a `serviceConfig` fragment; merge with `// { … }` so a service overrides single keys.
- Baseline: `NoNewPrivileges`, `PrivateTmp`, `ProtectSystem=strict`, `ProtectHome`, `MemoryDenyWriteExecute`, `SystemCallFilter=@system-service`, `ReadWritePaths`.
- Network: `RestrictAddressFamilies=[AF_INET AF_INET6 (+AF_UNIX)]`, or `PrivateNetwork` + `AF_UNIX` when `allowNetwork=false`.
- Unless `allowDevices`: `PrivateDevices`, `ProtectKernelModules/Tunables`, `RestrictNamespaces`, `ProtectControlGroups`, `LockPersonality`.
- `allowJIT`: `MemoryDenyWriteExecute=false`, `SystemCallFilter=""`.
- `extraHardening`: `CapabilityBoundingSet=""`, `RestrictSUIDSGID`, `ProtectKernelLogs`, `ProtectClock`, `ProtectHostname`, `ProtectProc=invisible`, `ProcSubset=pid`, `SystemCallArchitectures=native`, `RemoveIPC`, `UMask=0077`.
- Used by every observability unit with `extraHardening=true`; Alloy adds `allowJIT`; node_exporter and Alloy relax `/proc`; Grafana overrides `UMask=0027`.

**`mkDataDirPermissionsService { pkgs, dataDir, user, group, requiredBy }`** — root oneshot `RequiresMountsFor=dataDir` that `find -xdev … chown -h user:group` anything not owned correctly. Fixes (1) uid/gid drift and (2) the race where tmpfiles `d`/`Z` rules run before a separate `/data` mount exists. Instances: `loki-`, `grafana-`, `ntfy-`, `alloy-`, `prometheus-permissions`; each is `requiredBy` its service. It is `RemainAfterExit`, so it runs at boot and when its service starts from stopped, **not** again on a plain restart.

**`mkWalSelfHeal { pkgs, unit, walDir, user, group, errorPattern, keep=2, cooldownSeconds=3600 }`** — see §12.

**Others used here:** `mkNginxVirtualHost`, `mkFirewallPorts`, `mkSslAssertion` (domain/SSL plumbing, identical across modules). Setting a service's `domain` enables nginx, adds a virtual host proxying to it, and (when its `openFirewall` is true) opens ports 80 and 443 instead of the service port; `golden-domain-effects` pins this.

---

## 12. Resilience mechanisms

| Failure | Detection | Automatic action | Manual follow-up |
|---|---|---|---|
| Clock wrong at boot / sync late | `ClockDrift`, `ClockNotSynced` | Prometheus, Loki, Alloy start `after`/`wants` `time-sync.target`; the host is expected to make that target wait for `systemd-time-wait-sync` | |
| Prometheus up but TSDB head in the future / samples rejected | `PrometheusHeadInFuture`, `PrometheusSamplesOutOfBounds`, `PrometheusNoRecentSamples` | **`prometheus-tsdb-guard`** (timer: 15 min after boot, then every 5 min): if head is >1h ahead *or* >100 "out of bounds/too far into the future" log lines in 15 min → stop Prometheus, move `data/wal` and `data/chunks_head` to `*.broken-<ts>`, start it. 6-hour cooldown | Fix the clock first. Compacted blocks with future samples need manual removal — `PrometheusHeadInFuture` runbook |
| Prometheus/Loki crash-looping on a corrupt WAL | systemd failure; `PrometheusWALCorruption` | **`mkWalSelfHeal`**: unit gets `StartLimitBurst=3` in 300 s; on failure `<unit>-wal-recover` runs *only if* the last 15 min of journal matches `segments are not sequential\|wal.*corrupt\|corrupt.*wal\|checkpoint.*corrupt`; moves `walDir` to `walDir.broken-<ts>`, recreates it, resets failed state, starts the unit. Max once per hour; keeps 2 quarantines. Cost: data only in the WAL (minutes) is lost | If it fires often, find the cause (disk, power, clock) |
| Prometheus can't store anything (so metric alerts are unreliable) | `absent_over_time` rule | Alertmanager inhibits all other `category=observability` alerts for that instance; notifications still go out | `PrometheusNoRecentSamples` runbook |
| Alerts not reaching you | `PrometheusNoAlertmanager`, `PrometheusNotificationsFailing`, `AlertmanagerNotifyFailing` | — | `mon-check --fire-test` |
| Loki OOM/slow shutdown | — | `TimeoutStopSec=5min`, flush on shutdown | |
| Wrong ownership after rebuild | — | `*-permissions` oneshots every boot | |
| Grafana stale/renamed dashboards | — | pre-start cleanup of provisioned dashboards (daily DB backup first) | |

---

## 13. CI and testing

`nix flake check` (x86_64-linux) builds and validates the following on fake machines defined in `flake/ci/_harness/default.nix`: `stable` (stable nixpkgs with sops-nix and the `nsops--*` modules), `unstable`, `external` (a consumer with no sops-nix at all), `minimal` (only `enable = true`), and `domain` (a `domain` set on every service). No machine receives `specialArgs`, so a module that needs one fails here.

| Check | What it verifies |
|---|---|
| `prom-config-<host>`, `prom-rules-<host>`, `alertmanager-config-<host>` (`stable`, `unstable`, `external`) | Rendered `prometheus.yml` passes `promtool check config`; rendered rules pass `promtool check rules`; Alertmanager config passes `amtool check-config` after dummy-substituting every `$VAR` |
| `prom-rules-all-features` | Every rule with every feature flag on (`allFeatures`) is valid |
| `prom-rule-tests` | `promtool test rules` over `flake/ci/_tests/prometheus/*.test.yml`, rules rendered **without** `condition` label and runbook annotation |
| `runbook-coverage`, `loki-runbook-coverage` | Every Prometheus alert (all features) and every Loki-ruler alert has `docs/runbooks/<Alert>.md` or a line in `_todo.txt` |
| `loki-config`, `alloy-config` | The rendered Loki config passes `loki -verify-config`; the rendered Alloy config parses with `alloy fmt` |
| `dashboard-lint` | Each dashboard JSON has `uid`, `title`, `schemaVersion`; first threshold step is `null`; no unit `days` (use `d`); uids are unique |
| `maintenance-log-shellcheck`; the `mon-*` package builds | `maintenance-logger.sh` passes shellcheck; the three scripts pass shellcheck when packaged (`writeShellApplication`) |
| `port-defaults` | Every service's default port is the value in §0; a port can't move unnoticed |
| `golden-domain-effects` | Setting `domain` has exactly the recorded side effects (`flake/ci/_golden/domain-effects.json`: nginx, virtual hosts, firewall ports, failing assertions) |
| `nvidia-gated` | `NvidiaXid` is absent by default and present with `integrations.nvidia.enable` |
| `double-import` | Importing individual modules on top of the stack evaluates (module keys) |
| `toplevel-stable`, `toplevel-external`, `toplevel-minimal` | Whole-system builds of the fake machines |
| `no-nixlab-coupling` | Fails while any nixlab-internal dependency (`nixlabLib`, `hostMeta`, `allHosts`, `config.nixlab`, …) appears in modules, stacks, sops or flake code |
| `options-doc-fresh`, `docs-links` | `docs/reference/options.md` equals the generated reference; relative links in the README and docs resolve |
| `compat-names`, `compat-alias-targets`, `alias-priority`, `old-style-consumer` | **Until 0.4.0:** every deprecated module and option name still works, aliases point at real options, a `mkDefault` through an old name loses to a plain assignment through the new one |

Rule unit tests exist for: HostDown, CriticalDiskSpace (and absence of LowDiskSpace), ProbeFailed, HighCPULoad, NVMeHighTemperature (and absence of HighCPUTemperature), PrometheusConfigReloadFailed, PrometheusNoAlertmanager, SMARTStatusFailed, FilesystemReadOnly, ExpectedMountMissing, ZpoolNotOnline, BatteryHealthDegraded. Expected labels/annotations must match the rule exactly, so changing a summary or label means updating its test.

**Not in `checks`:** `nix build .#vm-smoke` boots a NixOS VM with the full stack and checks every service's readiness endpoint, that at least one scrape target is up and none is down, and that no unit has failed. It needs KVM, so CI runs it explicitly. Development packages: `.#options-doc` (regenerates the options reference), `.#goldens` (regenerates the golden files), `.#fingerprint` (a diffable dump of the rendered configs, for before/after comparisons during refactors).

**GitHub Actions** (`.github/workflows/`): `ci.yml` runs `nix flake check`, `vm-smoke` and the example build on every pull request and push to `main`; `release.yml` turns a `v*` tag into a GitHub release from the matching `CHANGELOG.md` section (release candidates become pre-releases); `update-flake-lock.yml` opens a weekly lock-update pull request.

Formatting: `nix fmt -- .` (alejandra).

---

## 14. Operations

### 14.1 Scripts

The three scripts ship as flake packages and apps, built with their own tools (`curl`, `jq`, `ss`, coreutils…; `systemctl`, `systemd-analyze` and `nix` come from the host). Run **on the host**:

```bash
nix run github:Temhr/observability/<tag>#mon-check [-- --fire-test]
nix run github:Temhr/observability/<tag>#mon-snapshot -- <outdir>
nix run github:Temhr/observability/<tag>#mon-unitdiff -- <old-system> <new-system>
```
(`bin/*.sh` are the sources and still run standalone.)

| Script | Use |
|---|---|
| `mon-check [--fire-test]` | Verifies: units active (`MON_UNITS`); readiness endpoints for Prometheus, Loki, Alertmanager, Grafana, ntfy; all scrape targets up; no rules in error (reports rules still waiting for first evaluation); Prometheus has ≥1 Alertmanager; Loki has labels. `--fire-test` posts a uniquely named warning to Alertmanager and polls the ntfy topic for up to 90 s (expect 30–60 s: `group_wait`). Exit code 0 = all passed. Env: `MON_HOST`, `MON_PROM_PORT`, `MON_LOKI_PORT`, `MON_GRAFANA_PORT`, `MON_AM_PORT`, `MON_NTFY_PORT`, `MON_TOPIC`, `MON_UNITS`, `MON_NTFY_AUTH=user:pass` (use the `reader` account; only needed when ntfy auth is on). |
| `mon-snapshot <outdir>` | Captures normalised `systemctl cat` of each unit (store hashes stripped), generated configs (`prometheus.yml`, `alerts.yml`, `loki.yaml`, `config.alloy`, `ntfy-server.yml`), Alertmanager's live config, listening sockets, and `systemd-analyze security` scores. Run before and after a change, then `diff -ru`. `MON_DATA` overrides `/data`. |
| `mon-unitdiff <old-system> <new-system>` | Diffs generated unit files between two system closures (e.g. `/run/current-system` and `./result`) plus `nix store diff-closures`. Use before switching. |

### 14.2 Routine procedures

**Deploy a change** (in the consuming repository). `git add -A` → `nix flake check` → build the host → `sudo nixos-rebuild switch --flake .#<host>` (or `test` first) → `mon-check` → `mon-check --fire-test` after anything touching Alertmanager/ntfy/secrets.

**Upgrade this flake.** Read `CHANGELOG.md` for the new tag (breaking changes and deprecations are listed; deprecated names keep working for one minor release and warn), change the tag in your flake input, `nix flake update observability`, build every host, deploy to **one** host, run `mon-check`, soak, then roll out.

**Rollout.** Deploy to one host, run `mon-check`, then the rest.

**Is it healthy?** Grafana → *System Monitoring & Maintenance Dashboard v5* → health score, alerts table, "Observability Stack Health" row; or `curl -s localhost:9090/api/v1/targets | jq '[.data.activeTargets[]|select(.health!="up")]'`.

**Log a maintenance task.** `sudo maintenance-log --section II.4 --task "Applied updates, rebooted" --status completed`. (File is wheel-writable.) Review in Grafana (Maintenance row) or Loki `{job="maintenance-log"}`.

**Silence an alert.** Alertmanager UI (`:9093`, only if exposed) or `amtool --alertmanager.url=http://127.0.0.1:9093 silence add alertname=<X>`.

**Change retention.** `services.observability.{loki.retention,prometheus.retention,prometheus.retentionSize}`; Loki needs a restart-time compaction cycle to delete.

**Restore.** Backups are in `<D>/backup` (`grafana.db.bak`, `cache.db.bak`, `user.db.bak`, `alertmanager/`, `maintenance.jsonl`). To restore Grafana: `systemctl stop grafana`, move the live `<D>/grafana/data/grafana.db` aside, copy `grafana.db.bak` to that path, **`chown grafana:grafana` it yourself** (the `grafana-permissions` unit is `RemainAfterExit`; it fixes ownership at boot, not on a plain restart), `systemctl start grafana`, then `mon-check`. ntfy's `user.db`/`cache.db` and Alertmanager's state directory are restored the same way (stop, copy back, fix ownership, start); keep the moved-aside copies until `mon-check` passes. Check a backup first: `sqlite3 <file>.bak 'PRAGMA integrity_check;'` must print `ok`.

### 14.3 Troubleshooting matrix

| Symptom | Look at |
|---|---|
| No notifications at all | `mon-check --fire-test`; `journalctl -u alertmanager`; `alertmanager_notifications_failed_total`; ntfy up? creds in the Alertmanager env file match? → runbook *AlertmanagerNotifyFailing* |
| Prometheus healthy but dashboards empty / `up` missing | Clock (`timedatectl`), `journalctl -u prometheus | grep -i 'out of bounds'`, TSDB head vs now → *PrometheusNoRecentSamples* / *PrometheusHeadInFuture* |
| Prometheus won't start | `promtool check config <D>/prometheus/prometheus.yml`; WAL errors → self-heal should act; `ls <D>/prometheus/data` for `*.broken-*` |
| Target down | `curl localhost:<port>/metrics`; service journal; firewall for remote scrapes (exporters are loopback by default) → *ServiceDown*, *HostDown* |
| Grafana dashboard missing/old | `journalctl -u grafana` (`grafana-setup:` lines); JSON must be `git add`ed; lint rules in §13; uid clashes |
| Grafana panels "No data" for Loki | datasource uid must be `loki`; `curl localhost:3100/loki/api/v1/labels` |
| "Time since each timer last fired" is empty or short | `services.observability-grafana.timersRegex` (default `nixos-upgrade.timer\|nix-gc.timer`) must match your timers |
| No logs in Loki | `systemctl status alloy`; `alloy` UI on `127.0.0.1:12345`; `AlloyDroppingEntries`; Loki rate limits (`LokiDiscardingSamples`) |
| Maintenance entries not in Loki | the maintenance log path must not end in `.log`; `loki.maintenance.enable = true`; Alloy can read the file (0664); `lokiJob` still the label the dashboard queries |
| ZFS member/scrub alerts never fire | `zfsMembers` is off by default; enable it and provide the textfile metrics (`docs/operations/zfs-metrics.md`); an absent metric never alerts |
| `NvidiaXid` never fires | `integrations.nvidia.enable` is off by default |
| Alert fires but no runbook link | `runbook` annotation only on deployed rules, requires `services.observability-prometheus.runbookBaseUrl` to be set |
| `nix flake check` fails `runbook-coverage` / `loki-runbook-coverage` | Add `docs/runbooks/<Alert>.md` or a line in `_todo.txt` |
| `nix flake check` fails a rule test | Exact label/annotation match required; test rules have no `condition` label |
| `nix flake check` fails `golden-domain-effects` | The side effects of `domain` changed. If intended: `nix build .#goldens -o /tmp/g && cp -L /tmp/g/*.json flake/ci/_golden/`, and say so in the CHANGELOG |
| `nix flake check` fails `options-doc-fresh` | `nix build .#options-doc -o /tmp/o && cp -L /tmp/o docs/reference/options.md` |
| `The option … does not exist` for an old name | The name is deprecated and was removed (0.4.0), or the alias list is stale; use the new name (see `public-api.md`) |
| Permission denied on data dir after restoring or rebuilding | uid changed or a copied file has the wrong owner; `chown` it, or reboot so `*-permissions` runs |

---

## 15. Extending the stack

**Contribution rules.** Write the test first (a failing check, then the change). New files must be `git add`ed before `nix` can see them. Run `nix fmt -- .` and `nix flake check` before you push. Anything specific to one deployment (host names, addresses, hardware only you have) belongs in the consumer's adapter, not here; if it must exist in this flake, make it an option that defaults off.

**Add an alert (Prometheus).**
1. Add the rule to the right group in `modules/nixos/prometheus/_internals/maintenance-alerts.nix` (`alert`, `expr`, `for`, `labels.{severity,category,checklist_section}`, `annotations.{summary,description}`).
2. If it depends on an optional exporter or metric, gate it: add `requires = "<flag>";` directly under the `alert = …;` line, add the flag as a boolean option (default `false`) under `maintenance.alerts.features` in `prometheus/_internals/options.nix`, and add `<flag> = true;` to the `allFeatures` binding in `flake/ci/observability-checks.nix` so the all-features, runbook and rule-test checks still see it. (`zfsMembers` is the worked example; `rendered.nix` passes the options through as features automatically.)
3. Write `docs/runbooks/<Alert>.md` from `_template.md` (or add the name to `_todo.txt`).
4. Add a test case to `flake/ci/_tests/prometheus/rules.test.yml`.
5. `git add -A && nix fmt -- . && nix flake check`.

**Add a log alert.** Append a rule to the `journal` group in `stacks/observability.nix` (`services.observability-loki.ruler.groups`); set `instance = "{{ $labels.host }}"` plus `severity`, `category`, `checklist_section`. To make it opt-in, put the rule behind `lib.optional cfg.integrations.<name>.enable` in the `rules` list (keep the order of the other rules) and add the option beside `integrations.nvidia.enable`. Write the runbook: `loki-runbook-coverage` fails without it.

**Add a scrape target.** Host-specific: `services.observability-prometheus.extraScrapeConfigs = [{ job_name = "x"; static_configs = [{ targets = ["127.0.0.1:1234"]; }]; }];`. Fleet-wide: add a `scrapeJob` to the stack, or an `integrations.*` entry plus an alert feature flag.

**Add a probe.** Set `services.observability-prometheus.maintenance.exporters.blackbox.{httpTargets,sslTargets,dnsTargets,tcpTargets,icmpTargets,httpInsecureTargets}` (requires `maintenance.enable`). The stack fills `icmpTargets` and `tcpTargets` from `probes.*`.

**Add a dashboard.** Drop `<name>.json` into `modules/nixos/grafana/dashboards/` (needs `uid`, `title`, `schemaVersion`; `steps[0].value = null`; unit `d` not `days`; use `${DS_PROMETHEUS}` or uid `loki`; include the hidden `prometheus_url` constant variable for deep-links), `git add`, then either add it to the module's default `dashboards` or enable per host with `extraDashboards = ["<name>"]`. A value a consumer must set (like the timer list) becomes a hidden constant variable (`timers_regex` is the example) filled from a Grafana option in the `jq` step of `grafana-provision`.

**Add a receiver/channel.** Set `notifications.useNtfy = false` (or add alongside), define `services.observability-alertmanager.receivers` and `route.routes`, put secrets in the Alertmanager environment file as `KEY=value` and reference `$KEY`. Receiver names are asserted at eval time.

**Add a monitored service to the consumer's fleet.** Expose `/metrics`, add a scrape job (host: `extraScrapeConfigs`; generally useful: a stack `scrapeJob` upstream), add alerts and runbooks, optionally a dashboard.

**Add a module to this flake.**
1. Create `modules/nixos/<name>/default.nix` registering `flake.nixosModules.servc--observability-<name>` (or `systm--…`), wrapped in `self.lib.obsLib.keyed "observability:<name>" ({config, lib, pkgs, ...}: …)`; options under `services.observability-<name>`, with an `enable`. The outer function takes `{self, ...}`.
2. Keep it atomic: no sibling options. Cross-wiring goes in `stacks/observability.nix`, which imports it and fills its escape hatches.
3. Port: the option's own `default` (add it to `port-defaults`). Data directory, user, uid/gid, `extraUsers` and the `*-permissions` unit follow the existing modules.
4. Regenerate the options reference (`nix build .#options-doc -o /tmp/o && cp -L /tmp/o docs/reference/options.md`), update `docs/architecture/public-api.md` and the CHANGELOG.

**Rename or remove a public name.** That is a breaking change: add a deprecation alias for one minor release, list it in `public-api.md`, and record the decision in an ADR.

---

## 17. Quick reference

**Option paths you will actually touch**
```
services.observability.{enable, access.{interfaces,expose}, publicHost, dataDir,
                        prometheus.{maintenance.enable,retention,retentionSize,scrapeInterval},
                        loki.{retention,maintenance.enable}, notifications.{ntfyAuth.enable,separateCritical,useNtfy,topics},
                        integrations.{traefik,cadvisor,postgres,nvidia}, probes.*}
services.observability-prometheus.{extraScrapeConfigs, maintenance.expectedMounts, maintenance.alerts.features.*,
                                   maintenance.exporters.blackbox.*, maintenance.exporters.smartctl.devices}
services.observability-alertmanager.{receivers, route.routes, inhibitRules, extraConfig, environmentFile | secretsFile}
services.observability-grafana.{extraDashboards, timersRegex, allowAnonymous, provisioning.datasources, credentialsFile, secretKeyFile | secretsFile}
services.observability-loki.{ruler.groups, retentionStreams}
services.observability-host-exporters.{nodeExporter.{enable,listenAddress,textfileDir}, smartctl.{enable,listenAddress}}
services.observability-maintenance-log.{logPath, textfileDir, lokiJob}
```

**Useful commands**
```bash
# state
systemctl status prometheus loki alloy grafana alertmanager ntfy prometheus-node-exporter
curl -s localhost:9090/api/v1/rules  | jq '[.data.groups[].rules[]|select(.health!="ok")]'
curl -s localhost:9090/api/v1/alerts | jq '.data.alerts[]|{alertname:.labels.alertname,state}'
curl -s localhost:9093/api/v2/alerts | jq '.[].labels.alertname'
curl -s localhost:3100/loki/api/v1/labels
curl -s localhost:2586/v1/health
# validate (in the flake's repository)
promtool check config /data/prometheus/prometheus.yml
nix build .#checks.x86_64-linux.prom-rule-tests
nix flake check
nix build .#vm-smoke                                  # needs KVM
# verify (on a host)
nix run github:Temhr/observability/<tag>#mon-check
MON_NTFY_AUTH=reader:<pw> nix run github:Temhr/observability/<tag>#mon-check -- --fire-test
nix run github:Temhr/observability/<tag>#mon-snapshot -- /tmp/before   # change; run again into /tmp/after; diff -ru /tmp/before /tmp/after
nix run github:Temhr/observability/<tag>#mon-unitdiff -- /run/current-system ./result
```

**Naming.** `servc--observability-<svc>` atomic service module · `systm--observability-<thing>` supporting module · `nsops--observability-<svc>` optional secrets wiring · `stack--observability` aggregator (also `default`) · `services.observability-<x>` a module's options, `services.observability` the aggregator's · `flake.lib.<name>` shared functions/data consumed by name · deprecated 0.2 names: `…-nixlab`, `services.nixlab-observability`, `nsops--alertmanager`, `nsops--grafana` (removed in 0.4.0; mapping in `docs/architecture/public-api.md`).

---

## Appendix: illustrative host configuration

*Derived from the option definitions, not copied from a real host. Adapt names and interfaces.*

```nix
# flake.nix of the consumer
inputs.observability = {
  url = "github:Temhr/observability/<tag>";        # pin a release tag, never a branch
  inputs.nixpkgs.follows = "nixpkgs";
};

# a host's module list
modules = [
  observability.nixosModules.default                              # = stack--observability
  observability.nixosModules.nsops--observability-alertmanager    # optional: sops-nix wiring
  observability.nixosModules.nsops--observability-grafana
  ./my-observability.nix
];
```
```nix
# ./my-observability.nix
{
  services.observability = {
    enable = true;
    access = {
      interfaces = [ "eno1" ];                       # only interfaces you trust (see the security note, §5.2)
      expose = [ "grafana" "ntfy" "prometheus" ];
    };
    publicHost = "192.0.2.10";
    probes.gateway = "192.0.2.1";
    prometheus = {
      maintenance.enable = true;                     # loads the full alert set + exporters
      retentionSize = "50GB";
    };
    loki.maintenance.enable = true;                  # maintenance-log helper + Alloy pipeline
    notifications.ntfyAuth.enable = true;            # needs NTFY_*_PASSWORD in the Alertmanager env file
    integrations.nvidia.enable = true;               # only on hosts with the NVIDIA driver
  };

  # secrets: files the consumer owns (sops-nix; the nsops modules above wire them)
  services.observability-alertmanager.secretsFile = ./secrets/alertmanager.env;
  services.observability-grafana.secretsFile = ./secrets/grafana.yaml;

  services.observability-prometheus.maintenance.expectedMounts = [ "/data" ];
  services.observability-prometheus.maintenance.alerts.features.zfsMembers = true;   # ZFS host only, with the textfile metrics
  services.observability-grafana.extraDashboards = [ "zfs-monitoring" ];            # ZFS host only
  services.observability-grafana.timersRegex = "nixos-upgrade.timer|nix-gc.timer|backup.timer";
}
```
