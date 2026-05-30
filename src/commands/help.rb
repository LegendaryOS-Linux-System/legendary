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
          usage: "legendary update [--system] [--flatpak] [--firmware]",
          desc:  "Aktualizuj system: obraz bootc/rpm-ostree · aplikacje Flatpak · firmware · Distrobox",
          color: Colors::ELECTRIC_BLUE,
          note:  "Wymaga sudo",
        },
        {
          name:  "build",
          usage: "legendary build <iso|cloud|--release>",
          desc:  "Zbuduj obraz LegendaryOS: ISO instalacyjny, obraz cloud lub pełny release",
          color: Colors::VIVID_MAGENTA,
          note:  "Wymaga legendaryos-builder",
        },
        {
          name:  "game",
          usage: "legendary game",
          desc:  "Uruchom Phoenix Runner — grę zręcznościową osadzoną w świecie LegendaryOS",
          color: Colors::PINK_MAGENTA,
        },
        {
          name:  "doctor",
          usage: "legendary doctor",
          desc:  "Diagnostyka systemu — sprawdź stan instalacji",
          color: Colors::SKY_CYAN,
        },
        {
          name:  "on motd",
          usage: "legendary on motd",
          desc:  "Włącz wyświetlanie MOTD przy logowaniu (usuwa plik .off)",
          color: Colors::SUCCESS,
        },
        {
          name:  "off motd",
          usage: "legendary off motd",
          desc:  "Wyłącz wyświetlanie MOTD przy logowaniu (tworzy plik .off)",
          color: Colors::WARNING,
        },
        {
          name:  "community",
          usage: "legendary community",
          desc:  "Pokaż media społecznościowe i linki projektu LegendaryOS",
          color: Colors::COBALT_BLUE,
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

          icon_s  = "#{c[:color]}#{Colors::BOLD}▸#{Colors::RESET}"
          usage_s = "#{c[:color]}#{Colors::BOLD}#{c[:usage]}#{Colors::RESET}"
          desc_s  = "#{Colors::BRIGHT_WHITE}#{c[:desc]}#{Colors::RESET}"
          note_s  = c[:note] ? "  #{Colors::SUBTLE}[#{c[:note]}]#{Colors::RESET}" : ""

          puts "  #{icon_s}  #{usage_s}#{note_s}"
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
