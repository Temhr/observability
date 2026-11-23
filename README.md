# observability

Prometheus, Alertmanager, ntfy, Loki, Alloy and Grafana as **composable NixOS modules**, plus one aggregator module that wires them together: provisioned datasources, scrape jobs, alert routing to push notifications, about 60 alerts with a runbook each, a manual maintenance log, nightly state backups and self-healing for the failure modes that make monitoring lie.

Every service is usable on its own; the aggregator is what you enable if you want the whole stack with one option. It was extracted from [nixlab](https://github.com/Temhr/nixlab), where it still monitors the author's fleet, and it contains nothing specific to that fleet.

## Quick start

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    observability = {
      url = "github:Temhr/observability/v0.3.0";   # pin a release tag, never a branch
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {nixpkgs, observability, ...}: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        observability.nixosModules.default
        {
          services.observability.enable = true;

          # Secrets are file paths; use sops-nix, agenix or anything that puts a file on disk.
          services.observability-alertmanager.environmentFile = "/run/secrets/alertmanager.env";
          services.observability-grafana.credentialsFile = "/run/secrets/grafana-admin-password";
          services.observability-grafana.secretKeyFile = "/run/secrets/grafana-secret-key";
        }
      ];
    };
  };
}
```

That is a complete, working stack. Nothing leaves loopback until you ask (see [Exposure](#exposure)); a complete example is in [`examples/minimal`](examples/minimal/flake.nix). Without the Grafana secret files it still works but warns that Grafana is using its insecure built-in secret key.

## What you get

| | |
|---|---|
| **Metrics** | Prometheus scraping itself, node_exporter, the other stack services and anything you add; optional smartctl, blackbox (HTTP, ICMP, TCP, TLS, DNS) and systemd exporters |
| **Logs** | Alloy ships the journal, `/var/log/*.log` and the maintenance log to Loki |
| **Dashboards** | Grafana with Prometheus, Loki and Alertmanager datasources pre-provisioned, a system overview dashboard and an opt-in ZFS dashboard |
| **Alerting** | Alertmanager routing to ntfy topics (priority, tags, per-category topics), inhibition rules, Prometheus alerts plus four Loki-ruler log alerts |
| **Runbooks** | One page per alert in [`docs/runbooks`](docs/runbooks/), linked from the notification; CI refuses an alert without one |
| **Maintenance log** | A `maintenance-log` command that records manual maintenance as JSON lines, ships it to Loki (kept two years) and exports "last completed" metrics |
| **Backups** | A nightly consistent copy of Grafana's and ntfy's databases, Alertmanager's state and the maintenance log |
| **Self-healing** | Quarantine of a corrupt WAL for Prometheus and Loki, a guard for a Prometheus TSDB whose clock went wrong, services ordered after time sync |

Default ports: Prometheus 9090, Alertmanager 9093, Grafana 3101, Loki 3100 (gRPC 9096, loopback), ntfy 2586, Alloy 12345 (loopback), node 9100, smartctl 9633, blackbox 9115.

## Modules

Importing a module starts nothing; each one has an `enable`. They can be imported alone, together, or through the aggregator, in any combination.

| Module (`observability.nixosModules.<name>`) | Purpose | Options under |
|---|---|---|
| `default` (= `stack--observability`) | the whole stack, wired together | `services.observability` |
| `servc--observability-prometheus` | metrics, rules, exporters | `services.observability-prometheus` |
| `servc--observability-alertmanager` | routing, inhibition, receivers | `services.observability-alertmanager` |
| `servc--observability-ntfy` | push notification server | `services.observability-ntfy` |
| `servc--observability-loki` | log store and LogQL ruler | `services.observability-loki` |
| `servc--observability-alloy` | log shipper | `services.observability-alloy` |
| `servc--observability-grafana` | dashboards | `services.observability-grafana` |
| `systm--observability-host-exporters` | node and smartctl exporters | `services.observability-host-exporters` |
| `systm--observability-maintenance-log` | maintenance log and its metrics | `services.observability-maintenance-log` |
| `systm--observability-backup` | state backups | `services.observability-backup` |
| `nsops--observability-alertmanager`, `nsops--observability-grafana` | **optional** [sops-nix](https://github.com/Mic92/sops-nix) wiring | adds `secretsFile` |

The full option list, with defaults and descriptions, is generated from the code: [`docs/reference/options.md`](docs/reference/options.md).

## Configuring the stack

The aggregator exposes a small, deliberate surface; each service's own options stay available for anything else.

```nix
services.observability = {
  enable = true;

  # Reachability: see "Exposure" below
  access.interfaces = [ "eno1" ];
  access.expose = [ "grafana" "ntfy" "prometheus" ];     # the default

  # Links in notifications and UIs, and what to probe
  publicHost = "192.0.2.10";
  probes.gateway = "192.0.2.1";
  probes.icmpTargets = [ "192.0.2.20" ];
  probes.tcpTargets = [ "127.0.0.1:8123" ];

  dataDir = "/data";                                      # each service gets a subdirectory

  prometheus = {
    maintenance.enable = true;                            # full alert set, smartctl/blackbox exporters
    scrapeInterval = "60s"; retention = "7d"; retentionSize = "4GB";
  };
  loki = { retention = "168h"; maintenance.enable = true; };

  notifications = {
    ntfyAuth.enable = true;                               # alertmanager (write) and reader (read) users
    topics.storage.matchers = [ ''category=~"storage|backup"'' ];   # also published to <topic>-storage
  };

  integrations.traefik.enable = true;                     # extra scrape job + matching alerts
};

services.observability-prometheus.maintenance.expectedMounts = [ "/data" ];     # alert if a mount is missing
services.observability-grafana.extraDashboards = [ "zfs-monitoring" ];
```

Tunables the stack sets are overridable either through `services.observability.*` or directly on the service (`services.observability-loki.*`). Wiring (datasources, scrape jobs, receivers) is additive: extend it with the services' `extraScrapeConfigs`, `receivers`, `route.routes`, `provisioning.datasources` and so on rather than replacing it.

## Exposure

Everything binds to loopback. A service leaves loopback only if it is listed in `access.expose` **and** an interface is named in `access.interfaces`; the firewall is then opened for those ports on those interfaces only. `openFirewall` (all interfaces) exists for compatibility and is discouraged. Interface names must be non-empty; omit interfaces the machine doesn't have.

> **Security note.** Prometheus, Loki and Alertmanager have **no authentication** here. Grafana has a login. ntfy is open to anyone who can reach it unless you set `notifications.ntfyAuth.enable = true`. Expose only on interfaces you trust, or put them behind a reverse proxy (`domain` on a service enables an nginx virtual host, and **opens ports 80 and 443** when `openFirewall` is on).

## Host prerequisites

Documented rather than enforced:

- the state root (`dataDir`, default `/data`) is mounted before the stack starts; the permission fixers wait for the mount
- `time-sync.target` really means the clock is set (Prometheus refuses samples from a clock that jumps); a laptop that may boot offline should not block on it
- journald, for log shipping
- nginx only if a service sets `domain`; a firewall only if you use `access.interfaces` or `openFirewall`
- SMART monitoring needs real disks and the exporter's access to them; ZFS member alerts need the textfile metrics described in [`docs/operations/zfs-metrics.md`](docs/operations/zfs-metrics.md)

## Secrets

No module references a secret manager. They take **file paths**: `services.observability-alertmanager.environmentFile` (KEY=VALUE, referenced as `$KEY` in receivers, so nothing enters the Nix store), `services.observability-grafana.credentialsFile` and `secretKeyFile`, and `services.observability.notifications.ntfyAuth.environmentFile` (defaults to Alertmanager's file; holds `NTFY_ALERTMANAGER_PASSWORD` and `NTFY_READER_PASSWORD`). If you use sops-nix, import the two `nsops--observability-*` modules and set `secretsFile`; they declare the secrets, set owners, and restart the right units when a secret changes. The repository ships no encrypted material. Rotation procedures: [`docs/operations/secret-rotation.md`](docs/operations/secret-rotation.md).

## Alerts

About 60 Prometheus alerts, grouped by the sections of a maintenance checklist (hardware, storage, OS, backups, network and security, services, containers, probes, observability self-health, SMART, filesystem, ZFS, battery), each labelled with `severity`, `category` and `checklist_section`, and carrying the exact expression that fired it as a `condition` label. Core groups (stack self-health, recording rules) always load; the rest load with `prometheus.maintenance.enable`, and rules that depend on an optional exporter load only when that integration is on. Alerts on metrics that don't exist stay silent. Log alerts (OOM kills, filesystem errors, SSH failure bursts, optionally NVIDIA Xid) are evaluated by Loki's ruler.

Browse them in [`docs/architecture/`](docs/architecture/) and their runbooks in [`docs/runbooks/`](docs/runbooks/).

## Operating it

Helper scripts ship as flake outputs and bring their own tools:

```bash
nix run github:Temhr/observability/v0.3.0#mon-check                   # units, endpoints, scrape targets, rules, Alertmanager link, Loki
nix run github:Temhr/observability/v0.3.0#mon-check -- --fire-test   # end to end: alert → Alertmanager → ntfy
nix run github:Temhr/observability/v0.3.0#mon-snapshot -- /tmp/before # generated configs and units, for before/after diffs
sudo maintenance-log --section II.4 --task "Applied updates" --status completed
```
`--fire-test` needs `MON_NTFY_AUTH=reader:<password>` when ntfy auth is on. More in [`docs/operations/`](docs/operations/): backup and restore, monitoring the monitor, upgrading.

## Testing

`nix flake check` builds and validates, on three fake machines (stable nixpkgs with sops-nix, unstable, and a consumer with no sops-nix at all):

- rendered Prometheus, Alertmanager, Loki and Alloy configuration (`promtool`, `amtool`, `loki -verify-config`, `alloy fmt`)
- every alert rule, rule unit tests, and runbook coverage for both Prometheus and Loki alerts
- dashboards (uids, thresholds, units), the helper scripts (shellcheck), pinned port defaults
- contract tests: importing modules twice is harmless, the side effects of setting `domain` are unchanged, the generated options reference and the docs links are current

`nix build .#vm-smoke` boots a NixOS VM with the full stack and checks every endpoint and that no scrape target is down (needs KVM). Details: [`docs/development/testing.md`](docs/development/testing.md).

## Stability and versioning

Pre-1.0: a minor release may break. The public interface is the exported module names, the documented options, persistent state paths, service identities (units, users, uids) and the secret-file interface; see [`docs/architecture/public-api.md`](docs/architecture/public-api.md). Everything else (`self.lib.*`, `_internals/`, the helper library) is internal. Renamed options and modules keep working for one minor release and print a warning. Every release is listed in [`CHANGELOG.md`](CHANGELOG.md); design decisions are recorded as [ADRs](docs/architecture/decisions/).

Supported: `x86_64-linux`, tested against `nixos-26.05` and `nixos-unstable`.

## Contributing

- Write the test first: a failing check, then the change.
- A new alert needs a runbook (`docs/runbooks/<Alert>.md`, from `_template.md`), a rule test, and the right `requires` gate if it depends on an optional exporter.
- New files must be `git add`ed before `nix` can see them; run `nix fmt` and `nix flake check` before you push.
- Anything specific to one deployment (host names, addresses, hardware you alone have) belongs in the consumer's adapter, not here. A CI check fails if nixlab-internal names creep back in.

Extending the stack (scrape targets, probes, dashboards, receivers, alerts): [`docs/development/extending.md`](docs/development/extending.md).

## Documentation

[`docs/README.md`](docs/README.md) is the index. In short: [architecture and public API](docs/architecture/), [options reference](docs/reference/options.md), [operations](docs/operations/), [runbooks](docs/runbooks/), [development](docs/development/).
