{
  ...
}:

let
  publicURL = "grafana.blakehaug.com";
in
{
  imports = [ ];

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
    ];
  };
  services.prometheus.exporters.node.enable = true;
  services.cadvisor.enable = true;

  # logs
  services.loki = {
    enable = true;
    configuration = {
      auth_enabled = false;
      server.http_listen_address = "127.0.0.1";
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

  # ships the systemd journal into loki
  services.alloy.enable = true;
  environment.etc."alloy/config.alloy".text = ''
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
    }

    loki.source.journal "journal" {
      relabel_rules = loki.relabel.journal.rules
      forward_to    = [loki.write.local.receiver]
      labels        = { job = "systemd-journal" }
    }

    loki.write "local" {
      endpoint {
        url = "http://127.0.0.1:3100/loki/api/v1/push"
      }
    }
  '';

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
