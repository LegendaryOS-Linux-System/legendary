require_relative "../colors"
require_relative "../banner"

module LegendaryOS
  module Commands
    class Motd
      include Colors

      MOTD_DIR     = File.join(Dir.home, ".config", "LegendaryOS", "motd")
      MOTD_OFF_FILE = File.join(MOTD_DIR, ".off")

      def enable
        Banner.print_mini_banner

        puts "  #{Colors::ELECTRIC_BLUE}#{Colors::BOLD}⚡  legendary on motd#{Colors::RESET}  " \
             "#{Colors::SUBTLE}— Włączanie MOTD#{Colors::RESET}"
        puts Colors.paint("  " + "─" * 60, Colors::DARK_VIOLET)
        puts

        unless File.exist?(MOTD_OFF_FILE)
          puts "  #{Colors::SUCCESS}#{Colors::BOLD}  ✔#{Colors::RESET}  " \
               "#{Colors::BRIGHT_WHITE}MOTD jest już włączone.#{Colors::RESET}"
          puts
          return
        end

        begin
          File.delete(MOTD_OFF_FILE)
          puts "  #{Colors::SUCCESS}#{Colors::BOLD}  ✔#{Colors::RESET}  " \
               "#{Colors::BRIGHT_WHITE}MOTD zostało #{Colors::SUCCESS}#{Colors::BOLD}włączone#{Colors::RESET}#{Colors::BRIGHT_WHITE}.#{Colors::RESET}"
          puts "  #{Colors::SUBTLE}     Plik #{Colors::INDIGO}#{MOTD_OFF_FILE}#{Colors::RESET}#{Colors::SUBTLE} został usunięty.#{Colors::RESET}"
        rescue StandardError => e
          puts "  #{Colors::ERROR}#{Colors::BOLD}  ✘  Błąd podczas włączania MOTD: #{e.message}#{Colors::RESET}"
          exit 1
        end

        puts
      end

      def disable
        Banner.print_mini_banner

        puts "  #{Colors::VIVID_MAGENTA}#{Colors::BOLD}⚡  legendary off motd#{Colors::RESET}  " \
             "#{Colors::SUBTLE}— Wyłączanie MOTD#{Colors::RESET}"
        puts Colors.paint("  " + "─" * 60, Colors::DARK_VIOLET)
        puts

        if File.exist?(MOTD_OFF_FILE)
          puts "  #{Colors::WARNING}#{Colors::BOLD}  ⚠#{Colors::RESET}  " \
               "#{Colors::BRIGHT_WHITE}MOTD jest już wyłączone.#{Colors::RESET}"
          puts "  #{Colors::SUBTLE}     Plik #{Colors::INDIGO}#{MOTD_OFF_FILE}#{Colors::RESET}#{Colors::SUBTLE} już istnieje.#{Colors::RESET}"
          puts
          return
        end

        begin
          require "fileutils"
          FileUtils.mkdir_p(MOTD_DIR)
          FileUtils.touch(MOTD_OFF_FILE)
          puts "  #{Colors::SUCCESS}#{Colors::BOLD}  ✔#{Colors::RESET}  " \
               "#{Colors::BRIGHT_WHITE}MOTD zostało #{Colors::WARNING}#{Colors::BOLD}wyłączone#{Colors::RESET}#{Colors::BRIGHT_WHITE}.#{Colors::RESET}"
          puts "  #{Colors::SUBTLE}     Utworzono: #{Colors::INDIGO}#{MOTD_OFF_FILE}#{Colors::RESET}"
        rescue StandardError => e
          puts "  #{Colors::ERROR}#{Colors::BOLD}  ✘  Błąd podczas wyłączania MOTD: #{e.message}#{Colors::RESET}"
          exit 1
        end

        puts
      end
    end
  end
end
