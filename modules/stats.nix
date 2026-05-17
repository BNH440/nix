{
  config,
  lib,
  ...
}:

let
  cfg = config.stats;
in
{
  options.stats = {
    enable = lib.mkEnableOption "node exporter and Alloy journal shipping";

    lokiUrl = lib.mkOption {
      type = lib.types.str;
      default = "http://127.0.0.1:3100/loki/api/v1/push";
      description = ''
        Loki push endpoint Alloy forwards the systemd journal to. Defaults to a
        Loki on the same host; point this at the monitoring host
        (e.g. http://ronri:3100/loki/api/v1/push) when shipping remotely.
      '';
    };

    zfsExporter = {
      enable = lib.mkEnableOption "Prometheus ZFS exporter";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      services.prometheus.exporters.node.enable = true;

      # let prometheus scrape via tailscale
      networking.firewall.interfaces."tailscale0".allowedTCPPorts = [
        9100 # node exporter
      ];

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
          labels        = { job = "systemd-journal", host = "${config.networking.hostName}" }
        }

        loki.write "local" {
          endpoint {
            url = "${cfg.lokiUrl}"
          }
        }
      '';
    })

    (lib.mkIf cfg.zfsExporter.enable {
      services.prometheus.exporters.zfs.enable = true;

      # let prometheus scrape via tailscale
      networking.firewall.interfaces."tailscale0".allowedTCPPorts = [
        config.services.prometheus.exporters.zfs.port
      ];
    })
  ];
}
