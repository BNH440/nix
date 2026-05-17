{
  pkgs,
  ...
}:

let
  publicURL = "grafana.blakehaug.com";

  # one prometheus timeseries panel
  promTs = id: x: y: title: expr: legend: {
    inherit id title;
    type = "timeseries";
    datasource = "Prometheus";
    gridPos = {
      inherit x y;
      w = 12;
      h = 8;
    };
    fieldConfig = {
      defaults.custom.fillOpacity = 10;
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
        inherit expr;
        legendFormat = legend;
      }
    ];
  };

  # an "include all" query template variable
  queryVar = name: datasource: query: {
    inherit name datasource query;
    type = "query";
    refresh = 2;
    includeAll = true;
    multi = true;
    current = {
      selected = false;
      text = "All";
      value = "$__all";
    };
  };

  base = {
    schemaVersion = 39;
    timezone = "browser";
    refresh = "30s";
    time = {
      from = "now-6h";
      to = "now";
    };
  };

  nodes = base // {
    uid = "nodes";
    title = "Nodes";
    templating.list = [ (queryVar "instance" "Prometheus" "label_values(node_uname_info, instance)") ];
    panels = [
      (promTs 1 0 0 "CPU busy %"
        ''100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle",instance=~"$instance"}[5m])) * 100)''
        "{{instance}}"
      )
      (promTs 2 12 0 "Memory used %"
        ''100 * (1 - node_memory_MemAvailable_bytes{instance=~"$instance"} / node_memory_MemTotal_bytes{instance=~"$instance"})''
        "{{instance}}"
      )
      (promTs 3 0 8 "Load (1m)" ''node_load1{instance=~"$instance"}'' "{{instance}}")
      (promTs 4 12 8 "Root FS used %"
        ''100 - (node_filesystem_avail_bytes{instance=~"$instance",mountpoint="/"} * 100 / node_filesystem_size_bytes{instance=~"$instance",mountpoint="/"})''
        "{{instance}}"
      )
      (promTs 5 0 16 "Net RX (B/s)"
        ''rate(node_network_receive_bytes_total{instance=~"$instance",device!="lo"}[5m])''
        "{{instance}} {{device}}"
      )
      (promTs 6 12 16 "Net TX (B/s)"
        ''rate(node_network_transmit_bytes_total{instance=~"$instance",device!="lo"}[5m])''
        "{{instance}} {{device}}"
      )
    ];
  };

  containers = base // {
    uid = "containers";
    title = "Containers";
    templating.list = [ ];
    panels = [
      (promTs 1 0 0 "Container CPU (cores)"
        ''sum by (name) (rate(container_cpu_usage_seconds_total{name!=""}[5m]))''
        "{{name}}"
      )
      (promTs 2 12 0 "Container memory (working set)"
        ''sum by (name) (container_memory_working_set_bytes{name!=""})''
        "{{name}}"
      )
    ];
  };

  logs = base // {
    uid = "syslogs";
    title = "System logs";
    time = {
      from = "now-1h";
      to = "now";
    };
    templating.list = [ (queryVar "host" "Loki" ''label_values({job="systemd-journal"}, host)'') ];
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
      name = "nodes.json";
      path = pkgs.writeText "nodes.json" (builtins.toJSON nodes);
    }
    {
      name = "containers.json";
      path = pkgs.writeText "containers.json" (builtins.toJSON containers);
    }
    {
      name = "logs.json";
      path = pkgs.writeText "logs.json" (builtins.toJSON logs);
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
        enforce_domain = true;
        enable_gzip = true;
        domain = "${publicURL}";
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
            targets = [ "127.0.0.1:8080" ];
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
            targets = [ "ito:8080" ];
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
      };
    };
  };

  security.acme.certs."blakehaug.com".extraDomainNames = [ publicURL ];
}
