# frozen_string_literal: true

require_relative "../colors"
require_relative "../banner"
require_relative "../system_info"

module LegendaryOS
  module Commands
    class Info
      include Colors

      def run
        Banner.print_mini_banner

        los = SystemInfo.legendary_os_version

        Banner.section("Tool Information")
        Banner.kv("Tool Name",     "legendary",              val_color: Colors::VIVID_MAGENTA + Colors::BOLD)
        Banner.kv("Tool Version",  LegendaryOS::VERSION,     val_color: Colors::PINK_MAGENTA + Colors::BOLD)
        Banner.kv("Language",      "Ruby #{RUBY_VERSION}",   val_color: Colors::ELECTRIC_BLUE)
        Banner.kv("Platform",      RUBY_PLATFORM,            val_color: Colors::PERIWINKLE)
        Banner.section_end

        Banner.section("LegendaryOS Information")
        Banner.kv("OS Version",    los[:version],
                  val_color: Colors::VIVID_MAGENTA + Colors::BOLD)
        Banner.kv("Release Date",  los[:release_date],  val_color: Colors::LAVENDER)
        Banner.kv("Base",          "#{los[:base]} #{los[:base_version]}", val_color: Colors::ELECTRIC_BLUE)
        Banner.kv("Edition",       los[:edition],       val_color: Colors::SKY_CYAN)
        Banner.kv("Architecture",  los[:architecture],  val_color: Colors::PERIWINKLE)
        Banner.kv("Boot System",   los[:boot_system],   val_color: Colors::COBALT_BLUE + Colors::BOLD)
        Banner.kv("Variant",       los[:variant],       val_color: Colors::LAVENDER)
        Banner.section_end

        Banner.section("Build")
        Banner.kv("Build ID",      los[:build_id],           val_color: Colors::MUTED)
        Banner.kv("Release Date",  los[:release_date],       val_color: Colors::INDIGO)
        Banner.kv("Image",         los[:image],              val_color: Colors::PERIWINKLE)
        Banner.section_end

        puts "  #{Colors::SUBTLE}Run #{Colors::BOLD}#{Colors::VIVID_MAGENTA}legendary status#{Colors::RESET}#{Colors::SUBTLE} for full system info.#{Colors::RESET}"
        puts "  #{Colors::SUBTLE}Run #{Colors::BOLD}#{Colors::ELECTRIC_BLUE}legendary doctor#{Colors::RESET}#{Colors::SUBTLE} to check system health.#{Colors::RESET}"
        puts
      end
    end
  end
end
