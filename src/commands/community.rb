require_relative "../colors"
require_relative "../banner"

module LegendaryOS
  module Commands
    class Community
      include Colors

      LINKS = [
        {
          label: "SourceForge",
          desc:  "Pobierz LegendaryOS — oficjalne wydania",
          url:   "https://sourceforge.net/projects/legendaryos/",
          color: Colors::VIVID_MAGENTA,
          icon:  "◈",
        },
        {
          label: "Strona internetowa",
          desc:  "Oficjalna strona projektu LegendaryOS",
          url:   "https://legendaryos-linux-system.github.io/website/",
          color: Colors::ELECTRIC_BLUE,
          icon:  "⬡",
        },
        {
          label: "Reddit",
          desc:  "Społeczność r/LegendaryOS — dyskusje, newsy, pomoc",
          url:   "https://www.reddit.com/r/LegendaryOS/",
          color: Colors::PINK_MAGENTA,
          icon:  "◉",
        },
        {
          label: "Forum (GitHub Discussions)",
          desc:  "Oficjalne forum — pytania, sugestie, dyskusje",
          url:   "https://github.com/orgs/LegendaryOS-Linux-System/discussions",
          color: Colors::SKY_CYAN,
          icon:  "◈",
        },
        {
          label: "Changelog",
          desc:  "Historia zmian i aktualizacji LegendaryOS",
          url:   "https://legendaryos-linux-system.github.io/website/changelog/index.html",
          color: Colors::LAVENDER,
          icon:  "◎",
        },
        {
          label: "Discord",
          desc:  "Serwer Discord — czat społeczności w czasie rzeczywistym",
          url:   "https://discord.gg/wqxT9SeXDB",
          color: Colors::COBALT_BLUE,
          icon:  "⬡",
        },
      ].freeze

      def run
        Banner.print_banner
        Banner.section("Społeczność LegendaryOS")
        puts

        LINKS.each do |link|
          icon_s  = "#{link[:color]}#{Colors::BOLD}#{link[:icon]}#{Colors::RESET}"
          label_s = "#{link[:color]}#{Colors::BOLD}#{link[:label]}#{Colors::RESET}"
          desc_s  = "#{Colors::SUBTLE}#{link[:desc]}#{Colors::RESET}"
          url_s   = "#{Colors::INDIGO}#{Colors::UNDERLINE}#{link[:url]}#{Colors::RESET}"

          puts "  #{icon_s}  #{label_s}"
          puts "       #{desc_s}"
          puts "       #{url_s}"
          puts
        end

        Banner.section_end

        puts "  #{Colors::SUBTLE}legendary v#{LegendaryOS::VERSION} — The CLI for LegendaryOS#{Colors::RESET}"
        puts "  #{Colors::SUBTLE}Uruchom #{Colors::BOLD}#{Colors::VIVID_MAGENTA}legendary help#{Colors::RESET}#{Colors::SUBTLE} aby zobaczyć dostępne komendy.#{Colors::RESET}"
        puts
      end
    end
  end
end
