{
  cfg,
  lib,
}:
{
  auth_enabled = false;

  analytics = {
    reporting_enabled = false;
  };

  server = {
    http_listen_address = cfg.listenAddress;
    http_listen_port = cfg.port;
    grpc_listen_address = "127.0.0.1";
    grpc_listen_port = cfg.grpcPort;
    log_level = "info";
  };

  common = {
    instance_addr = "127.0.0.1";
    path_prefix = cfg.dataDir;
    storage = {
      filesystem = {
        chunks_directory = "${cfg.dataDir}/chunks";
        rules_directory = "${cfg.dataDir}/rules";
      };
    };
    replication_factor = 1;
    ring = {
      kvstore = {
        store = "inmemory";
      };
    };
  };

  query_range = {
    results_cache = {
      cache = {
        embedded_cache = {
          enabled = true;
          max_size_mb = 100;
        };
      };
    };
  };

  schema_config = {
    configs = [
      {
        from = "2023-01-01";
        store = "tsdb";
        object_store = "filesystem";
        schema = "v13";
        index = {
          prefix = "index_";
          period = "24h";
        };
      }
    ];
  };

  limits_config =
    {
      retention_period = cfg.retention;
      max_query_series = 10000;
      max_query_lookback = "17520h";
      # Guardrails: a runaway unit must not fill /data on a laptop.
      ingestion_rate_mb = 4;
      ingestion_burst_size_mb = 8;
      per_stream_rate_limit = "3MB";
      per_stream_rate_limit_burst = "10MB";
      reject_old_samples = true;
      reject_old_samples_max_age = "168h";
      max_entries_limit_per_query = 5000;
    }
    // lib.optionalAttrs (cfg.retentionStreams != []) {
      retention_stream = map (s: {inherit (s) selector priority period;}) cfg.retentionStreams;
    };

  compactor = {
    working_directory = "${cfg.dataDir}/compactor";
    retention_enabled = true;
    retention_delete_delay = "2h";
    retention_delete_worker_count = 150;
    delete_request_store = "filesystem";
  };

  ingester = {
    wal = {
      enabled = true;
      dir = "${cfg.dataDir}/wal";
      flush_on_shutdown = true;
    };
    lifecycler = {
      address = "127.0.0.1";
      ring = {
        kvstore = {
          store = "inmemory";
        };
        replication_factor = 1;
      };
    };
  };

  memberlist = {
    join_members = [];
  };
}
// lib.optionalAttrs cfg.ruler.enable {
  ruler = {
    storage = {
      type = "local";
      local.directory = "${cfg.dataDir}/rules";
    };
    rule_path = "${cfg.dataDir}/rules-tmp";
    alertmanager_url = cfg.ruler.alertmanagerUrl;
    ring.kvstore.store = "inmemory";
    enable_api = true;
  };
}
