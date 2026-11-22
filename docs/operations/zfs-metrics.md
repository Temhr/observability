# ZFS member and scrub metrics

Six alerts watch ZFS health through metrics that **node_exporter does not produce**. They stay off until you enable them and provide the metrics described here.

## Enable the alerts

```nix
services.observability-prometheus.maintenance.alerts.features.zfsMembers = true;
```

Without this flag the six alerts below are not loaded. Two other ZFS alerts, `ZpoolNotOnline` and `ZpoolLowFree`, use node_exporter's own ZFS collector and are always on when maintenance alerts are on.

**An absent metric never alerts.** If nothing writes one of these metrics, the alert that depends on it stays silent forever; for example, no scrub metrics means `ZpoolScrubOverdue` can never fire. After enabling the flag, confirm every metric below is present (see [Verify](#verify)).

## The six metrics

All six are gauges. A **pool** is a ZFS pool name (`tank`); a **device** is the leaf disk identifier you use in `zpool status`, preferably the `/dev/disk/by-id/…` name.

| Metric | Labels | Value | Used by alert |
|---|---|---|---|
| `zfs_vdev_errors` | `pool`, `device`, `vdev_type`, `type` | the error counter from `zpool status`, one series per vdev and error type | `ZpoolDeviceErrors` (warning): fires when any series is above 0 for 2 minutes |
| `zfs_pool_error_count` | `pool` | the number of permanent data errors the pool reports ("errors: N data errors") | `ZpoolDataErrors` (critical): above 0 for 1 minute |
| `zfs_last_scrub_end_timestamp_seconds` | `pool` | Unix time (seconds) when the last scrub **completed** | `ZpoolScrubOverdue` (warning): `time()` minus this is more than 10 days for 1 hour |
| `zfs_last_scrub_errors` | `pool` | the number of errors the last completed scrub found and could not repair | `ZpoolScrubErrors` (warning): above 0 for 5 minutes; stays until the next clean scrub completes |
| `zfs_expected_device_present` | `pool`, `device` | `1` if the device's by-id path exists on the host, `0` if it is missing | `ZpoolMemberMissing` (critical): equal to 0 for 1 minute |
| `zfs_device_last_auto_online_timestamp_seconds` | `pool`, `device` | Unix time when your tooling last re-onlined this device automatically; `0` if it never has | `ZpoolMemberReonlined` (warning): re-onlined within the last hour |

### Label values

- `pool`: the pool name, the same on every metric that has it.
- `device`: the same identifier on every metric that has it, so a device's presence, errors and re-online time line up.
- `vdev_type`: `disk` for a leaf disk. Any other value (for example the name of a mirror or raidz group, or the pool itself) is treated as a parent vdev. The dashboard's "Disk Errors" tile counts only `vdev_type="disk"`.
- `type`: the kind of error, `read`, `write` or `checksum`, so the alert can say which one is rising.

### Also used by the dashboard

The optional `zfs-monitoring` dashboard also reads `zfs_expected_device_online{pool, device}`: `1` when `zpool status` lists the device as ONLINE, `0` otherwise. No alert depends on it. It is useful because ZFS only notices a failed disk when I/O reaches it, so "present" (the operating system's view) and "online" (ZFS's view) can disagree for a while.

## Who must write them

**Your host must.** This repository ships no producer. The metrics are written by something you run on each ZFS host (a systemd timer and script, for example) as a **textfile collector file**: a plain-text `*.prom` file in node_exporter's textfile directory.

- **Directory.** `/var/lib/node_exporter` by default. It is the value of `services.observability-host-exporters.nodeExporter.textfileDir`, which the Prometheus module sets when `services.observability-prometheus.maintenance.enable` is on. The directory is owned by the `prometheus` user, mode 0755.
- **File name.** Any `*.prom` name that is not already used, for example `zfs.prom`. Do **not** reuse `maintenance.prom` or `backup_metrics.prom`, which the stack writes.
- **One writer per metric.** The same metric name must not appear in two files, or node_exporter reports a scrape error for the textfile collector.
- **Write atomically.** Write to a temporary file in the same directory, then rename it over the target. A half-written file produces broken metrics.
- **Permissions.** The file must be readable by the node_exporter user (`prometheus`): mode 0644.
- **Cadence.** Presence checks every 30 seconds to 1 minute (the dashboard describes presence as updated every 30 seconds); error counters and scrub times every 5 minutes are enough. The alerts' `for` durations assume a refresh at least that often.

### Example file

```
# HELP zfs_vdev_errors Error counter reported by zpool status, per vdev and error type.
# TYPE zfs_vdev_errors gauge
zfs_vdev_errors{pool="tank",device="ata-EXAMPLE_DISK_1",vdev_type="disk",type="read"} 0
zfs_vdev_errors{pool="tank",device="ata-EXAMPLE_DISK_1",vdev_type="disk",type="write"} 0
zfs_vdev_errors{pool="tank",device="ata-EXAMPLE_DISK_1",vdev_type="disk",type="checksum"} 0
# HELP zfs_pool_error_count Permanent data errors in the pool.
# TYPE zfs_pool_error_count gauge
zfs_pool_error_count{pool="tank"} 0
# HELP zfs_last_scrub_end_timestamp_seconds Unix time the last scrub completed.
# TYPE zfs_last_scrub_end_timestamp_seconds gauge
zfs_last_scrub_end_timestamp_seconds{pool="tank"} 1795000000
# HELP zfs_last_scrub_errors Errors the last completed scrub could not repair.
# TYPE zfs_last_scrub_errors gauge
zfs_last_scrub_errors{pool="tank"} 0
# HELP zfs_expected_device_present 1 if the device's by-id path exists, 0 if missing.
# TYPE zfs_expected_device_present gauge
zfs_expected_device_present{pool="tank",device="ata-EXAMPLE_DISK_1"} 1
# HELP zfs_device_last_auto_online_timestamp_seconds Unix time the device was last re-onlined automatically (0 = never).
# TYPE zfs_device_last_auto_online_timestamp_seconds gauge
zfs_device_last_auto_online_timestamp_seconds{pool="tank",device="ata-EXAMPLE_DISK_1"} 0
```

Emit **one series per configured member disk** for the per-device metrics, including disks that are currently missing (`zfs_expected_device_present` at `0`); a missing disk that simply drops out of the file looks like "no data" and never alerts.

## Verify

On the host, as root:

```bash
ls -l /var/lib/node_exporter/                         # your zfs .prom file is there, mode 0644, recent timestamp
curl -s http://127.0.0.1:9100/metrics | grep '^zfs_'  # all six metric names appear, with the labels above
curl -s http://127.0.0.1:9100/metrics | grep -E '^node_textfile_scrape_error'   # prints 0 (non-zero means a bad or duplicated file)
curl -s 'http://127.0.0.1:9090/api/v1/query?query=count(zfs_expected_device_present)' | jq .   # a non-empty result once Prometheus has scraped
```

Then check each metric is present in Prometheus (Grafana → Explore, or the query above with each name). Finally, test an alert end to end if you can do so safely, for example by temporarily writing `zfs_expected_device_present{…} 0` for a test device and waiting for `ZpoolMemberMissing`, then restoring the file.

## Related

Runbooks: `ZpoolDeviceErrors`, `ZpoolDataErrors`, `ZpoolScrubOverdue`, `ZpoolScrubErrors`, `ZpoolMemberMissing`, `ZpoolMemberReonlined`, and the always-on `ZpoolNotOnline` and `ZpoolLowFree`. The `zfs-monitoring` dashboard is opt-in: `services.observability-grafana.extraDashboards = [ "zfs-monitoring" ];`.
