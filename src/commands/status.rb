require_relative "../colors"
require_relative "../banner"
require_relative "../system_info"

module LegendaryOS
  module Commands
    class Status
      include Colors

      def run
        Banner.print_banner

        los  = SystemInfo.legendary_os_version
        kcm  = SystemInfo.kcm_distro_info
        osr  = SystemInfo.os_release

        # ── LegendaryOS ──────────────────────────────────────────
        Banner.section("LegendaryOS")
        Banner.kv("Version",        los[:version],
                  key_color: Colors::LABEL, val_color: Colors::VIVID_MAGENTA + Colors::BOLD)
        Banner.kv("Release Date",   los[:release_date], val_color: Colors::LAVENDER)
        Banner.kv("Edition",        los[:edition],      val_color: Colors::ELECTRIC_BLUE)
        Banner.kv("Architecture",   los[:architecture], val_color: Colors::PERIWINKLE)
        Banner.kv("Variant",        los[:variant],      val_color: Colors::SKY_CYAN)
        Banner.kv("Boot System",    los[:boot_system],  val_color: Colors::COBALT_BLUE + Colors::BOLD)
        Banner.section_end

        # ── Fedora Base ───────────────────────────────────────────
        Banner.section("Fedora Base")
        fedora_str = SystemInfo.fedora_version
        Banner.kv("Fedora Version", los[:base_version], val_color: Colors::ELECTRIC_BLUE + Colors::BOLD)
        Banner.kv("Release String", fedora_str,         val_color: Colors::PERIWINKLE)
        Banner.kv("Variant/Edition", osr["VARIANT_ID"] || osr["VARIANT"] || "bootc/immutable",
                  val_color: Colors::SKY_CYAN)
        Banner.section_end

        # ── KDE / KCM Info ────────────────────────────────────────
        unless kcm.empty?
          Banner.section("Desktop Info (KCM)")
          kcm.each do |key, val|
            Banner.kv(key, val, val_color: Colors::LAVENDER)
          end
          Banner.section_end
        end

        # ── System ────────────────────────────────────────────────
        Banner.section("System")
        Banner.kv("Hostname",   SystemInfo.hostname,       val_color: Colors::BRIGHT_WHITE)
        Banner.kv("Kernel",     SystemInfo.kernel_version, val_color: Colors::PERIWINKLE)
        Banner.kv("Arch",       SystemInfo.architecture,   val_color: Colors::ELECTRIC_BLUE)
        Banner.kv("Uptime",     SystemInfo.uptime,         val_color: Colors::SKY_CYAN)
        Banner.section_end

        puts
      end
    end
  end
end
