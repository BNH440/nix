{
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
      name = "cadvisor.json";
      path = pkgs.writeText "cadvisor.json" (communityDashboard {
        id = 14282;
        rev = 1;
        hash = "1kfm2z43a8736c81jzir939xd58inyfbf4lh4v173bgqi85mma3n";
      });
    }
    {
      name = "system-logs.json";
      path = pkgs.writeText "system-logs.json" (builtins.toJSON logs);
    }
  ];
in
{
  imports = [ ];

  stats.enable = true;

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
        job_name = "ronri-cadvisor";
        scrape_interval = "15s";
        static_configs = [
          {
            targets = [ "127.0.0.1:8081" ];
            labels.instance = "ronri";
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
        job_name = "ito-cadvisor";
        scrape_interval = "15s";
        static_configs = [
          {
            targets = [ "ito:8081" ];
            labels.instance = "ito";
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
