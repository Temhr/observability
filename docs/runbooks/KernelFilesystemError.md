# KernelFilesystemError

**What it means.** The kernel reported a filesystem or block-device error on this host within the last 5 minutes: possible disk failure or corruption.

**What fires it.** Severity `critical`, category `storage`, checklist section III.8. A Loki-ruler alert: it counts kernel journal lines matching `EXT4-fs error`, XFS `Corruption` or `I/O error`, `BTRFS error` or `critical`, `Remounting filesystem read-only` or `I/O error, dev` over 5 minutes and fires when the count is above 0. It clears about 5 minutes after the last line. It does not appear in Prometheus' `ALERTS` series. While it fires, Alertmanager suppresses `warning` alerts in the same category (`storage`) for the same host, so check storage warnings directly (below).

**Likely causes.**
1. A failing disk, cable, backplane or controller (look for SMART or NVMe alerts on the same host).
2. An unclean shutdown or power loss that left a filesystem inconsistent.
3. For a virtual machine: the storage behind the virtual disk is full, slow or unavailable.

**First three commands.**
1. `journalctl -k --since "-1h" | grep -iE 'EXT4-fs|XFS|BTRFS|read-only|I/O error, dev'` — which device (`dev sdX`, `nvme0n1`) and filesystem, and whether it was remounted read-only.
2. `findmnt -rno TARGET,SOURCE,FSTYPE,OPTIONS | grep -E ',ro(,|$)|\sro(,|$)'; sudo smartctl -H -A /dev/<device-from-step-1>` — any filesystem now read-only, and the drive's own health verdict and error counters.
3. `zpool status -x` if the host uses ZFS (healthy output is "all pools are healthy"), or `btrfs device stats <mountpoint>` on Btrfs.

**Fix.** Treat it as a possible disk failure until shown otherwise. Copy off anything important **first** while the filesystem is still readable. If a disk is failing, replace it and restore or resilver from backup. If SMART is clean and the cause was a power loss, check the filesystem **while it is unmounted** (boot rescue media or `systemctl rescue`): `e2fsck -f` for ext4, `xfs_repair` for XFS, `btrfs check` / `btrfs scrub` for Btrfs; never run a repair tool on a mounted filesystem. If only cabling is suspected, reseat the cable or drive, then re-check SMART and the error counters.

**Escalate when.** Any read-only remount of the root filesystem or a data mount; SMART reports `FAILED` or growing bad sectors; errors continue after a reseat or fsck; more than one device reports errors; or you see signs of data corruption. Stop writing to the volume and back up before doing anything else.

**Related alerts.** `FilesystemReadOnly`, `FilesystemDeviceError`, `SMARTStatusFailed`, `SMARTSectorsGrowing`, `SMARTErrorLogGrowing`, `SCSIUncorrectedErrors`, `NVMeMediaErrors`, `NVMeCriticalWarning`, `ZpoolDeviceErrors`, `ZpoolNotOnline`, `CriticalDiskSpace`.
