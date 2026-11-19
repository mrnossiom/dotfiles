{
  flake.modules.nixos.weird_row-loki =
    { config, ... }:
    {
      config = {
        local.ports.loki = 9007;

        services.prometheus.scrapeConfigs = [
          {
            job_name = "loki";
            static_configs = [
              {
                targets = [ "localhost:${toString config.services.loki.configuration.server.http_listen_port}" ];
              }
            ];
          }
        ];

        services.loki = {
          enable = true;

          configuration = {
            auth_enabled = false;
            server = {
              http_listen_port = config.local.ports.loki.number;
            };
            common = {
              path_prefix = config.services.loki.dataDir;
              storage.filesystem = {
                chunks_directory = "${config.services.loki.dataDir}/chunks";
                rules_directory = "${config.services.loki.dataDir}/rules";
              };
              replication_factor = 1;
              ring.kvstore.store = "inmemory";
              ring.instance_addr = "127.0.0.1";
            };
            schema_config.configs = [
              {
                from = "2026-01-01";
                store = "tsdb";
                object_store = "filesystem";
                schema = "v13";
                index.prefix = "index_";
                index.period = "24h";
              }
            ];
            limits_config = {
              retention_period = "120h";
              ingestion_burst_size_mb = 16;
              reject_old_samples_max_age = "12h";
              max_global_streams_per_user = 20000;
              split_queries_by_interval = "24h";
            };
            compactor = {
              retention_enabled = true;
              compaction_interval = "10m";
              working_directory = "${config.services.loki.dataDir}/compactor";
              retention_delete_delay = "2h";
              delete_request_store = "filesystem";
            };
          };
        };

        systemd.services.alloy.serviceConfig.SupplementaryGroups = [ "caddy" ];

        services.alloy.enable = true;

        environment.etc."alloy/config.alloy".text = ''
          loki.write "default" {
            endpoint {
              url = "http://localhost:${config.local.ports.loki.string}/loki/api/v1/push"
            }
          }

          // Process journald logs
          loki.source.journal "read" {
            max_age       = "12h"
            forward_to    = [loki.process.journal.receiver]
            relabel_rules = loki.relabel.journal.rules
            labels        = { job = "journal" }
          }
          loki.relabel "journal" {
            forward_to = []
            rule {
              source_labels = ["__journal__systemd_unit"]
              target_label  = "unit"
            }
            rule {
              source_labels = ["__journal__hostname"]
              target_label  = "host"
            }
            rule {
              source_labels = ["__journal_priority_keyword"]
              target_label  = "level"
            }
            rule {
              source_labels = ["__journal_syslog_identifier"]
              target_label  = "syslog_identifier"
            }
          }
          loki.process "journal" {
            forward_to = [loki.write.default.receiver]
          }

          // Scrape standalone syslog files
          local.file_match "syslog" {
            path_targets = [{ __path__ = "/var/log/*.log" }]
          }
          loki.source.file "syslog" {
            targets    = local.file_match.syslog.targets
            forward_to = [loki.process.syslog.receiver]
          }
          loki.process "syslog" {
            forward_to = [loki.write.default.receiver]
            stage.static_labels {
              values = { job = "syslog" }
            }
          }
          // Scrape caddy access files
          local.file_match "caddy_access" {
            path_targets = [{ __path__ = "/var/log/caddy/*.log" }]
          }
          loki.source.file "caddy_access" {
            targets    = local.file_match.caddy_access.targets
            forward_to = [loki.process.caddy_access.receiver]
          }
          loki.process "caddy_access" {
            forward_to = [loki.write.default.receiver]
            stage.static_labels {
              values = { job = "caddy_access" }
            }
          }
        '';
      };
    };
}
