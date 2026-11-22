{
  cfg,
  hostName,
}: ''
  // Loki client for sending logs
  loki.write "local" {
    endpoint {
      url = "${cfg.lokiUrl}"
    }
  }

  // Collect systemd journal logs
  // journald exposes metadata as internal __journal_* labels. They are dropped
  // unless relabelled to a name without the "__" prefix.
  loki.relabel "journal" {
    forward_to = []

    rule {
      source_labels = ["__journal__systemd_unit"]
      target_label  = "unit"
    }
    rule {
      source_labels = ["__journal_priority_keyword"]
      target_label  = "level"
    }
    rule {
      source_labels = ["__journal__transport"]
      target_label  = "transport"
    }
  }

  loki.source.journal "systemd" {
    max_age       = "12h"
    relabel_rules = loki.relabel.journal.rules
    labels = {
      job  = "systemd-journal",
      host = "${hostName}",
    }

    forward_to = [loki.process.systemd.receiver]
  }

  loki.process "systemd" {
    forward_to = [loki.write.local.receiver]

    stage.static_labels {
      values = {
        job  = "systemd-journal",
        host = "${hostName}",
      }
    }

    stage.label_keep {
      values = ["job", "host", "unit", "level", "transport"]
    }
  }

  // Collect system log files
  local.file_match "varlogs" {
    path_targets = [{
      __address__ = "localhost",
      __path__    = "/var/log/*.log",
    }]
  }

  loki.source.file "varlogs" {
    targets    = local.file_match.varlogs.targets
    forward_to = [loki.process.varlogs.receiver]
  }

  loki.process "varlogs" {
    forward_to = [loki.write.local.receiver]

    stage.static_labels {
      values = {
        job  = "varlogs",
        host = "${hostName}",
      }
    }
  }
''
