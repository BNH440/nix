{
  config,
  pkgs,
  ...
}:

let
  publicURL = "grafana.blakehaug.com";

  # community dashboard JSON, pinned by revision. Provisioned dashboards skip
  # the import-time __inputs prompt, so swap the ${DS_*} placeholder for the
  # datasource name (legacy string datasource fields resolve by name).
  communityDashboard =
    {
      id,
      rev,
      hash,
    }:
    builtins.replaceStrings [ "\${DS_PROMETHEUS}" "\${DS_LOKI}" ] [ "Prometheus" "Loki" ] (
      builtins.readFile (
        pkgs.fetchurl {
          url = "https://grafana.com/api/dashboards/${toString id}/revisions/${toString rev}/download";
          sha256 = hash;
        }
      )
    );

  # journal logs board: no community equivalent matches {job="systemd-journal"}
  logs = {
    uid = "syslogs";
    title = "System logs";
    schemaVersion = 39;
    timezone = "browser";
    refresh = "30s";
    time = {
      from = "now-1h";
      to = "now";
    };
    templating.list = [
      {
        name = "host";
        type = "query";
        datasource = "Loki";
        query = ''label_values({job="systemd-journal"}, host)'';
        refresh = 2;
        includeAll = true;
        multi = true;
        current = {
          selected = false;
          text = "All";
          value = "$__all";
        };
      }
    ];
    panels = [
      {
        id = 1;
        title = "Log volume by level";
        type = "timeseries";
        datasource = "Loki";
        gridPos = {
          x = 0;
          y = 0;
          w = 24;
          h = 6;
        };
        fieldConfig = {
          defaults.custom = {
            drawStyle = "bars";
            fillOpacity = 60;
            stacking.mode = "normal";
          };
          overrides = [ ];
        };
        options = {
          legend = {
            displayMode = "list";
            placement = "bottom";
          };
          tooltip.mode = "multi";
        };
        targets = [
          {
            refId = "A";
            expr = ''sum by (level) (count_over_time({job="systemd-journal", host=~"$host"} [$__auto]))'';
            legendFormat = "{{level}}";
          }
        ];
      }
      {
        id = 2;
        title = "Logs";
        type = "logs";
        datasource = "Loki";
        gridPos = {
          x = 0;
          y = 6;
          w = 24;
          h = 18;
        };
        options = {
          showTime = true;
          wrapLogMessage = true;
          sortOrder = "Descending";
          enableLogDetails = true;
        };
        targets = [
          {
            refId = "A";
            expr = ''{job="systemd-journal", host=~"$host"}'';
          }
        ];
      }
    ];
  };

  zfs = {
    uid = "zfs";
    title = "ZFS";
    schemaVersion = 39;
    timezone = "browser";
    refresh = "30s";
    time = {
      from = "now-6h";
      to = "now";
    };
    templating.list = [
      {
        name = "pool";
        type = "query";
        datasource = "Prometheus";
        query = "label_values(zfs_pool_size_bytes, pool)";
        refresh = 2;
        includeAll = true;
        multi = true;
        current = {
          selected = false;
          text = "All";
          value = "$__all";
        };
      }
      {
        name = "type";
        type = "query";
        datasource = "Prometheus";
        query = "label_values(zfs_dataset_used_bytes, type)";
        refresh = 2;
        includeAll = false;
        multi = false;
        current = {
          selected = false;
          text = "filesystem";
          value = "filesystem";
        };
      }
      {
        name = "dataset";
        type = "query";
        datasource = "Prometheus";
        query = ''label_values(zfs_dataset_used_bytes{pool=~"$pool", type=~"$type"}, name)'';
        refresh = 2;
        includeAll = true;
        multi = true;
        current = {
          selected = false;
          text = "All";
          value = "$__all";
        };
      }
    ];
    panels = [
      {
        id = 1;
        title = "Pool health";
        type = "stat";
        datasource = "Prometheus";
        gridPos = {
          x = 0;
          y = 0;
          w = 6;
          h = 4;
        };
        fieldConfig = {
          defaults = {
            mappings = [
              {
                type = "value";
                options = {
                  "0" = {
                    text = "ONLINE";
                    color = "green";
                  };
                  "1" = {
                    text = "DEGRADED";
                    color = "orange";
                  };
                  "2" = {
                    text = "FAULTED";
                    color = "red";
                  };
                  "3" = {
                    text = "OFFLINE";
                    color = "red";
                  };
                  "4" = {
                    text = "UNAVAIL";
                    color = "red";
                  };
                  "5" = {
                    text = "REMOVED";
                    color = "red";
                  };
                  "6" = {
                    text = "SUSPENDED";
                    color = "red";
                  };
                };
              }
            ];
          };
          overrides = [ ];
        };
        options = {
          reduceOptions = {
            calcs = [ "lastNotNull" ];
            fields = "";
            values = false;
          };
          orientation = "auto";
          textMode = "auto";
        };
        targets = [
          {
            refId = "A";
            expr = ''zfs_pool_health{pool=~"$pool"}'';
            legendFormat = "{{pool}}";
          }
        ];
      }
      {
        id = 2;
        title = "Pool capacity used";
        type = "gauge";
        datasource = "Prometheus";
        gridPos = {
          x = 6;
          y = 0;
          w = 6;
          h = 4;
        };
        fieldConfig = {
          defaults = {
            unit = "percentunit";
            min = 0;
            max = 1;
            thresholds = {
              mode = "absolute";
              steps = [
                {
                  color = "green";
                  value = null;
                }
                {
                  color = "orange";
                  value = 0.8;
                }
                {
                  color = "red";
                  value = 0.9;
                }
              ];
            };
          };
          overrides = [ ];
        };
        options = {
          reduceOptions = {
            calcs = [ "lastNotNull" ];
            fields = "";
            values = false;
          };
          showThresholdLabels = false;
          showThresholdMarkers = true;
        };
        targets = [
          {
            refId = "A";
            expr = ''zfs_pool_allocated_bytes{pool=~"$pool"} / zfs_pool_size_bytes{pool=~"$pool"}'';
            legendFormat = "{{pool}}";
          }
        ];
      }
      {
        id = 3;
        title = "Pool fragmentation";
        type = "stat";
        datasource = "Prometheus";
        gridPos = {
          x = 12;
          y = 0;
          w = 6;
          h = 4;
        };
        fieldConfig = {
          defaults = {
            unit = "percentunit";
          };
          overrides = [ ];
        };
        options = {
          reduceOptions = {
            calcs = [ "lastNotNull" ];
            fields = "";
            values = false;
          };
          orientation = "auto";
          textMode = "auto";
        };
        targets = [
          {
            refId = "A";
            expr = ''zfs_pool_fragmentation_ratio{pool=~"$pool"}'';
            legendFormat = "{{pool}}";
          }
        ];
      }
      {
        id = 4;
        title = "Pool dedup ratio";
        type = "stat";
        datasource = "Prometheus";
        gridPos = {
          x = 18;
          y = 0;
          w = 6;
          h = 4;
        };
        fieldConfig = {
          defaults = {
            unit = "none";
          };
          overrides = [ ];
        };
        options = {
          reduceOptions = {
            calcs = [ "lastNotNull" ];
            fields = "";
            values = false;
          };
          orientation = "auto";
          textMode = "auto";
        };
        targets = [
          {
            refId = "A";
            expr = ''zfs_pool_deduplication_ratio{pool=~"$pool"}'';
            legendFormat = "{{pool}}";
          }
        ];
      }
      {
        id = 5;
        title = "Pool allocated vs free";
        type = "timeseries";
        datasource = "Prometheus";
        gridPos = {
          x = 0;
          y = 4;
          w = 24;
          h = 7;
        };
        fieldConfig = {
          defaults = {
            unit = "bytes";
            custom = {
              stacking = {
                mode = "normal";
              };
            };
          };
          overrides = [ ];
        };
        options = {
          legend = {
            displayMode = "list";
            placement = "bottom";
          };
          tooltip.mode = "multi";
        };
        targets = [
          {
            refId = "A";
            expr = ''zfs_pool_allocated_bytes{pool=~"$pool"}'';
            legendFormat = "{{pool}} allocated";
          }
          {
            refId = "B";
            expr = ''zfs_pool_free_bytes{pool=~"$pool"}'';
            legendFormat = "{{pool}} free";
          }
        ];
      }
      {
        id = 6;
        title = "Top datasets by used bytes";
        type = "bargauge";
        datasource = "Prometheus";
        gridPos = {
          x = 0;
          y = 11;
          w = 12;
          h = 8;
        };
        fieldConfig = {
          defaults = {
            unit = "bytes";
          };
          overrides = [ ];
        };
        options = {
          displayMode = "basic";
          orientation = "horizontal";
          reduceOptions = {
            calcs = [ "lastNotNull" ];
            fields = "";
            values = false;
          };
        };
        targets = [
          {
            refId = "A";
            expr = ''topk(10, zfs_dataset_used_bytes{pool=~"$pool", type=~"$type"})'';
            legendFormat = "{{name}}";
          }
        ];
      }
      {
        id = 7;
        title = "Dataset used vs available";
        type = "timeseries";
        datasource = "Prometheus";
        gridPos = {
          x = 12;
          y = 11;
          w = 12;
          h = 8;
        };
        fieldConfig = {
          defaults = {
            unit = "bytes";
          };
          overrides = [ ];
        };
        options = {
          legend = {
            displayMode = "list";
            placement = "bottom";
          };
          tooltip.mode = "multi";
        };
        targets = [
          {
            refId = "A";
            expr = ''zfs_dataset_used_bytes{pool=~"$pool", type=~"$type", name=~"$dataset"}'';
            legendFormat = "{{name}} used";
          }
          {
            refId = "B";
            expr = ''zfs_dataset_available_bytes{pool=~"$pool", type=~"$type", name=~"$dataset"}'';
            legendFormat = "{{name}} available";
          }
        ];
      }
    ];
  };

  dashboardDir = pkgs.linkFarm "grafana-dashboards" [
    {
      name = "node-exporter-full.json";
      path = pkgs.writeText "node-exporter-full.json" (communityDashboard {
        id = 1860;
        rev = 45;
        hash = "11hrll7fm626ikbva5md4gm0rca537vp4xsxa9sxl1pk15s6nk0q";
      });
    }
    {
      name = "system-logs.json";
      path = pkgs.writeText "system-logs.json" (builtins.toJSON logs);
    }
    {
      name = "zfs.json";
      path = pkgs.writeText "zfs.json" (builtins.toJSON zfs);
    }
  ];
in
{
  imports = [ ];

  stats.enable = true;

  age.secrets.grafana-github-oauth.rekeyFile = ../../secrets/grafana-github-oauth.age;

  systemd.services.grafana.serviceConfig.EnvironmentFile =
    config.age.secrets.grafana-github-oauth.path;

  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = 3000;
        enable_gzip = true;
        domain = "${publicURL}";
        # without this Grafana builds redirects from domain:http_port over http
        root_url = "https://${publicURL}/";
      };
      analytics.reporting_enabled = false;
      auth.disable_login_form = true;
      "auth.github" = {
        enabled = true;
        allow_sign_up = true;
        scopes = "read:org,user:email";
        role_attribute_path = "[login=='BNH440'][0] && 'GrafanaAdmin'";
        role_attribute_strict = true;
        allow_assign_grafana_admin = true;
      };
    };
    provision = {
      enable = true;
      datasources.settings.datasources = [
        {
          name = "Prometheus";
          type = "prometheus";
          url = "http://127.0.0.1:9090";
          isDefault = true;
          editable = false;
        }
        {
          name = "Loki";
          type = "loki";
          url = "http://127.0.0.1:3100";
          editable = false;
        }
      ];
      dashboards.settings = {
        apiVersion = 1;
        providers = [
          {
            name = "default";
            options.path = dashboardDir;
          }
        ];
      };
    };
  };

  # db
  services.prometheus = {
    enable = true;
    scrapeConfigs = [
      {
        job_name = "ronri-node";
        scrape_interval = "15s";
        static_configs = [
          {
            targets = [ "127.0.0.1:9100" ];
          }
        ];
      }
      {
        job_name = "ito-node";
        scrape_interval = "15s";
        static_configs = [
          {
            targets = [ "ito:9100" ];
          }
        ];
      }
      {
        job_name = "ito-zfs";
        static_configs = [
          { targets = [ "ito:9134" ]; }
        ];
      }
      {
        job_name = "kako-node";
        scrape_interval = "15s";
        static_configs = [
          {
            targets = [ "kako:9100" ];
          }
        ];
      }
    ];
  };

  # log store
  services.loki = {
    enable = true;
    configuration = {
      auth_enabled = false;
      server.http_listen_address = "0.0.0.0";
      common = {
        instance_addr = "127.0.0.1";
        path_prefix = "/var/lib/loki";
        replication_factor = 1;
        ring.kvstore.store = "inmemory";
        storage.filesystem = {
          chunks_directory = "/var/lib/loki/chunks";
          rules_directory = "/var/lib/loki/rules";
        };
      };
      schema_config.configs = [
        {
          from = "2024-01-01";
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
  };

  # allow pushing of logs to loki over tailscale
  networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 3100 ];

  services.nginx.virtualHosts = {
    "${publicURL}" = {
      useACMEHost = "blakehaug.com";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:3000";
        proxyWebsockets = true;
        recommendedProxySettings = true;
      };
    };
  };

  security.acme.certs."blakehaug.com".extraDomainNames = [ publicURL ];
}
