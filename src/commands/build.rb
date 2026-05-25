require_relative "../colors"
require_relative "../banner"

module LegendaryOS
    module Commands
        class Build
            include Colors

            BUILDER_BIN = "/usr/bin/legendaryos-builder"

            TARGETS = {
                "iso"   => {
                            label:   "ISO Image",
                            desc:    "Buduje instalacyjny obraz ISO systemu LegendaryOS",
                            color:   Colors::VIVID_MAGENTA,
                            icon:    "◈",
                            args:    ["build", "iso"],
                            },
                "cloud" => {
                            label:   "Cloud Image",
                            desc:    "Buduje obraz cloud (qcow2/raw) dla środowisk wirtualnych",
                            color:   Colors::ELECTRIC_BLUE,
                            icon:    "⬡",
                            args:    ["build", "cloud"],
                            },
                }.freeze

            RELEASE_FLAG = "--release"

            def initialize(args = [])
                @args    = Array(args)
                @release = @args.delete(RELEASE_FLAG) || @args.delete("release")
                @target  = @args.first&.downcase&.strip
            end

            def run
                Banner.print_mini_banner

                puts "  #{Colors::VIVID_MAGENTA}#{Colors::BOLD}◈  legendary build#{Colors::RESET}  " \
                        "#{Colors::SUBTLE}— Budowanie obrazów LegendaryOS#{Colors::RESET}"
                puts Colors.paint("  " + "─" * 60, Colors::DARK_VIOLET)
                puts

                check_builder_present!

                if @target.nil? && !@release
                    print_usage
                    exit 0
                end

                if @release
                    run_release_build
                elsif TARGETS.key?(@target)
                    run_target_build(@target)
                else
                    unknown_target!
                end
            end

            private

            # ── Tryb --release ──────────────────────────────────────────────────────

            def run_release_build
                puts "  #{Colors::PINK_MAGENTA}#{Colors::BOLD}◈  Tryb: Release Build#{Colors::RESET}"
                puts "  #{Colors::SUBTLE}Budowanie oficjalnego wydania LegendaryOS…#{Colors::RESET}"
                puts

                print_build_info(label: "Release", color: Colors::PINK_MAGENTA, icon: "◈",
                                 desc: "Pełny build release — ISO + Cloud + podpisywanie")
                puts

                confirm_or_exit("Czy na pewno chcesz zbudować release? (tak/nie): ")

                handoff([BUILDER_BIN, "build", RELEASE_FLAG])
            end

            # ── Tryb target (iso / cloud) ────────────────────────────────────────────

            def run_target_build(target)
                meta = TARGETS[target]

                puts "  #{meta[:color]}#{Colors::BOLD}#{meta[:icon]}  Tryb: #{meta[:label]}#{Colors::RESET}"
                puts "  #{Colors::SUBTLE}#{meta[:desc]}#{Colors::RESET}"
                puts

                print_build_info(label: meta[:label], color: meta[:color], icon: meta[:icon],
                                 desc: meta[:desc])
                puts

                handoff([BUILDER_BIN] + meta[:args])
            end

            # ── Helpers ─────────────────────────────────────────────────────────────

            def print_build_info(label:, color:, icon:, desc:)
                puts Colors.paint("  " + "─" * 60, Colors::DARK_VIOLET)
                puts "  #{color}#{Colors::BOLD}  #{icon}  #{label}#{Colors::RESET}"
                puts "  #{Colors::SUBTLE}     #{desc}#{Colors::RESET}"
                puts "  #{Colors::SUBTLE}     Builder: #{Colors::INDIGO}#{BUILDER_BIN}#{Colors::RESET}"
                puts Colors.paint("  " + "─" * 60, Colors::DARK_VIOLET)
            end

            def print_usage
                puts "  #{Colors::BOLD}#{Colors::BRIGHT_WHITE}Użycie:#{Colors::RESET}"
                puts
                puts "  #{Colors::ELECTRIC_BLUE}#{Colors::BOLD}legendary build iso#{Colors::RESET}"
                puts "  #{Colors::SUBTLE}     Buduje obraz ISO systemu LegendaryOS#{Colors::RESET}"
                puts
                puts "  #{Colors::VIVID_MAGENTA}#{Colors::BOLD}legendary build cloud#{Colors::RESET}"
                puts "  #{Colors::SUBTLE}     Buduje obraz cloud (qcow2/raw)#{Colors::RESET}"
                puts
                puts "  #{Colors::PINK_MAGENTA}#{Colors::BOLD}legendary build --release#{Colors::RESET}"
                puts "  #{Colors::SUBTLE}     Buduje pełne wydanie release (wymaga sudo)#{Colors::RESET}"
                puts
                puts Colors.paint("  " + "─" * 60, Colors::DARK_VIOLET)
                puts
                puts "  #{Colors::SUBTLE}Builder binary: #{Colors::INDIGO}#{BUILDER_BIN}#{Colors::RESET}"
                puts
            end

            def confirm_or_exit(prompt)
                print "  #{Colors::WARNING}#{Colors::BOLD}#{prompt}#{Colors::RESET}"
                answer = $stdin.gets&.strip&.downcase
                return if %w[tak t yes y].include?(answer)

                puts
                puts "  #{Colors::SUBTLE}Anulowano.#{Colors::RESET}"
                puts
                exit 0
            end

            def handoff(cmd)
                puts "  #{Colors::SUBTLE}Przekazuję sterowanie do #{Colors::BOLD}#{Colors::INDIGO}legendaryos-builder#{Colors::RESET}#{Colors::SUBTLE}…#{Colors::RESET}"
                puts
                exec(*cmd)
            rescue Errno::ENOENT
                fail_and_exit("Nie można uruchomić: #{cmd.first}")
            end

            def check_builder_present!
                return if File.exist?(BUILDER_BIN)

                fail_and_exit(
                    "#{BUILDER_BIN} nie istnieje!\n" \
                "  #{Colors::SUBTLE}Zainstaluj legendaryos-builder aby używać tej komendy.#{Colors::RESET}"
                )
            end

            def unknown_target!
                puts "  #{Colors::ERROR}#{Colors::BOLD}✘  Nieznany cel build: '#{@target}'#{Colors::RESET}"
                puts
                puts "  #{Colors::SUBTLE}Dostępne cele: #{Colors::BOLD}#{TARGETS.keys.join(", ")}#{Colors::RESET}"
                puts "  #{Colors::SUBTLE}Lub użyj flagi: #{Colors::BOLD}--release#{Colors::RESET}"
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
