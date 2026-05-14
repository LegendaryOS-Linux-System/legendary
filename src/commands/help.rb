# frozen_string_literal: true

require_relative "../colors"
require_relative "../banner"

module LegendaryOS
  module Commands
    class Help
      include Colors

      COMMANDS = [
        {
          name:  "status",
          usage: "legendary status",
          desc:  "Pokaż pełny status systemu — wersja LegendaryOS, Fedora, KCM, hardware",
          color: Colors::VIVID_MAGENTA,
        },
        {
          name:  "update",
          usage: "legendary update [--bootc] [--flatpak] [--firmware]",
          desc:  "Aktualizuj system: obraz bootc · aplikacje Flatpak · firmware",
          color: Colors::ELECTRIC_BLUE,
          note:  "Wymaga sudo",
        },
        {
          name:  "doctor",
          usage: "legendary doctor",
          desc:  "Diagnostyka systemu — sprawdź stan instalacji",
          color: Colors::SKY_CYAN,
        },
        {
          name:  "info",
          usage: "legendary info",
          desc:  "Szybki przegląd wersji narzędzia i systemu",
          color: Colors::LAVENDER,
        },
        {
          name:  "help",
          usage: "legendary help [command]",
          desc:  "Wyświetl tę pomoc",
          color: Colors::PERIWINKLE,
        },
        {
          name:  "version",
          usage: "legendary version",
          desc:  "Wydrukuj wersję narzędzia i zakończ",
          color: Colors::INDIGO,
        },
      ].freeze

      def run(cmd = nil)
        Banner.print_banner

        Banner.section("Dostępne komendy")
        puts

        COMMANDS.each do |c|
          next if cmd && c[:name] != cmd

          icon    = "#{c[:color]}#{Colors::BOLD}▸#{Colors::RESET}"
          usage_s = "#{c[:color]}#{Colors::BOLD}#{c[:usage]}#{Colors::RESET}"
          desc_s  = "#{Colors::BRIGHT_WHITE}#{c[:desc]}#{Colors::RESET}"
          note_s  = c[:note] ? "  #{Colors::SUBTLE}[#{c[:note]}]#{Colors::RESET}" : ""

          puts "  #{icon}  #{usage_s}#{note_s}"
          puts "       #{Colors::SUBTLE}#{desc_s}#{Colors::RESET}"
          puts
        end

        Banner.section_end

        puts "  #{Colors::SUBTLE}legendary v#{LegendaryOS::VERSION} — The CLI for LegendaryOS#{Colors::RESET}"
        puts "  #{Colors::SUBTLE}Source: #{Colors::INDIGO}https://github.com/legendaryos/legendary#{Colors::RESET}"
        puts
      end
    end
  end
end
