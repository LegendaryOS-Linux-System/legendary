require_relative "../colors"
require_relative "../banner"

module LegendaryOS
  module Commands
    class Update
      include Colors

      UPDATER_BIN = "/usr/bin/legendaryos-update"

      # Mapowanie flag CLI na argumenty legendaryos-update
      STAGE_FLAGS = {
        "system"   => "--system",
        "flatpak"  => "--flatpak",
        "firmware" => "--firmware",
      }.freeze

      def initialize(args = [])
        @args = Array(args)
      end

      def run
        Banner.print_mini_banner

        puts "  #{Colors::VIVID_MAGENTA}#{Colors::BOLD}⚡  legendary update#{Colors::RESET}  " \
             "#{Colors::SUBTLE}— Aktualizacja systemu LegendaryOS#{Colors::RESET}"
        puts Colors.paint("  " + "─" * 60, Colors::DARK_VIOLET)
        puts

        check_updater_present!
        check_root!

        update_args = build_args

        puts "  #{Colors::LABEL}#{Colors::BOLD}Zakresy aktualizacji:#{Colors::RESET}"
        print_stages(update_args)
        puts

        puts Colors.paint("  " + "─" * 60, Colors::DARK_VIOLET)
        puts

        puts "  #{Colors::SUBTLE}Przekazuję sterowanie do #{Colors::BOLD}#{Colors::INDIGO}legendaryos-update#{Colors::RESET}#{Colors::SUBTLE}…#{Colors::RESET}"
        puts

        cmd = [UPDATER_BIN] + update_args
        exec(*cmd)
      rescue Errno::ENOENT
        fail_and_exit("Nie można uruchomić: #{UPDATER_BIN}")
      end

      private

      def build_args
        # Normalizuj: usuń wiodące "--" jeśli użytkownik podał --system itp.
        normalized = @args.map { |a| a.sub(/^--/, "") }
        stages = normalized.select { |a| STAGE_FLAGS.key?(a) }

        if stages.empty?
          []  # brak flag → legendaryos-update zaktualizuje wszystko
        else
          stages.map { |s| STAGE_FLAGS[s] }.compact
        end
      end

      def print_stages(update_args)
        all = update_args.empty?
        stages = [
          { flag: "--system",   label: "System Image (bootc / rpm-ostree)", color: Colors::VIVID_MAGENTA, icon: "⬡" },
          { flag: "--flatpak",  label: "Flatpak Applications",              color: Colors::ELECTRIC_BLUE, icon: "⬡" },
          { flag: "--firmware", label: "Firmware (fwupd)",                  color: Colors::SKY_CYAN,      icon: "⬡" },
        ]

        stages.each do |s|
          active  = all || update_args.include?(s[:flag])
          icon_s  = active ? "#{s[:color]}#{Colors::BOLD}  #{s[:icon]}#{Colors::RESET}" \
                           : "#{Colors::SUBTLE}  ○#{Colors::RESET}"
          label_s = active ? "#{s[:color]}#{Colors::BOLD}#{s[:label]}#{Colors::RESET}" \
                           : "#{Colors::SUBTLE}#{s[:label]} (pominięty)#{Colors::RESET}"
          puts "  #{icon_s}  #{label_s}"
        end
      end

      def check_updater_present!
        return if File.exist?(UPDATER_BIN)

        fail_and_exit(
          "#{UPDATER_BIN} nie istnieje!\n" \
          "  #{Colors::SUBTLE}Zainstaluj go: sudo install -m 0755 legendaryos-update /usr/bin/legendaryos-update#{Colors::RESET}"
        )
      end

      def check_root!
        return if Process.uid == 0

        puts "  #{Colors::WARNING}#{Colors::BOLD}⚠  Aktualizacja systemu wymaga uprawnień root.#{Colors::RESET}"
        puts
        puts "  #{Colors::SUBTLE}Uruchom ponownie jako root:#{Colors::RESET}"
        puts "  #{Colors::BOLD}#{Colors::VIVID_MAGENTA}  sudo legendary update#{Colors::RESET}"
        puts
        exit 1
      end

      def fail_and_exit(msg)
        puts "  #{Colors::ERROR}#{Colors::BOLD}✘  #{msg}#{Colors::RESET}"
        puts
        exit 1
      end
    end
  end
end
