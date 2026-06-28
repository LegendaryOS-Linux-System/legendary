require_relative "../colors"
require_relative "../banner"

module LegendaryOS
    module Commands
        class Game
            include Colors

            # Gosu environment - instalowana per-user, nie wymagane sudo
            VENV_BASE    = File.join(Dir.home, ".legendaryos", "venvs", "legendary")
            GEM_HOME     = File.join(VENV_BASE, "gems")
            GOSU_VERSION = "~> 1.4"

            # Stała ścieżka do gry LegendaryOS-Game:
            GAME_ENTRY = "/usr/share/LegendaryOS/tools/LegendaryOS-Game/main.rb"
            GAME_DIR   = File.dirname(GAME_ENTRY)

            def run
                Banner.print_mini_banner

                puts "  #{Colors::VIVID_MAGENTA}#{Colors::BOLD}⚡  legendary game#{Colors::RESET}  " \
                        "#{Colors::SUBTLE}— LegendaryOS Phoenix Runner#{Colors::RESET}"
                puts Colors.paint("  " + "─" * 60, Colors::DARK_VIOLET)
                puts

                unless File.exist?(GAME_ENTRY)
                    fail_and_exit("Nie znaleziono gry: #{GAME_ENTRY}")
                end

                ensure_gosu_available!
                launch_game!
            end

            private

            # ── Gosu availability ────────────────────────────────────────────────────

            def gosu_available_globally?
                require "gosu"
                true
            rescue LoadError
                false
            end

            def gosu_available_in_venv?
                gosu_spec = Dir.glob(File.join(GEM_HOME, "gems", "gosu-*")).first
                return false unless gosu_spec

                ext_glob = File.join(gosu_spec, "**", "gosu.{so,bundle}")
                !Dir.glob(ext_glob).empty?
            end

            def ensure_gosu_available!
                if gosu_available_globally?
                    puts "  #{Colors::SUCCESS}#{Colors::BOLD}  ✔#{Colors::RESET}  #{Colors::BRIGHT_WHITE}Gosu dostępny globalnie#{Colors::RESET}"
                    puts
                    return
                end

                if gosu_available_in_venv?
                    puts "  #{Colors::SUCCESS}#{Colors::BOLD}  ✔#{Colors::RESET}  #{Colors::BRIGHT_WHITE}Gosu dostępny w środowisku: #{Colors::SUBTLE}#{GEM_HOME}#{Colors::RESET}"
                    puts
                    return
                end

                puts "  #{Colors::WARNING}#{Colors::BOLD}  ⚠#{Colors::RESET}  #{Colors::BRIGHT_WHITE}Gosu nie jest zainstalowany — konfiguruję środowisko…#{Colors::RESET}"
                puts
                setup_venv!
            end

            # ── Venv setup ───────────────────────────────────────────────────────────

            def setup_venv!
                print_setup_header
                check_system_dependencies!
                create_venv_dirs!
                install_gosu!
                puts
                puts "  #{Colors::SUCCESS}#{Colors::BOLD}  ✔#{Colors::RESET}  #{Colors::BRIGHT_WHITE}Środowisko gotowe!#{Colors::RESET}"
                puts
            end

            def print_setup_header
                puts Colors.paint("  " + "─" * 60, Colors::DARK_VIOLET)
                puts "  #{Colors::ROYAL_PURPLE}#{Colors::BOLD}  ◈  Konfiguracja środowiska Gosu#{Colors::RESET}"
                puts "  #{Colors::SUBTLE}     GEM_HOME: #{GEM_HOME}#{Colors::RESET}"
                puts "  #{Colors::SUBTLE}     Gra:      #{GAME_ENTRY}#{Colors::RESET}"
                puts Colors.paint("  " + "─" * 60, Colors::DARK_VIOLET)
                puts
            end

            def check_system_dependencies!
                puts "  #{Colors::ELECTRIC_BLUE}#{Colors::BOLD}  ›#{Colors::RESET}  #{Colors::BRIGHT_WHITE}Sprawdzam zależności systemowe…#{Colors::RESET}"

                missing = []

                pkg_checks = {
                    "libGL"      => "/usr/lib64/libGL.so.1",
                    "SDL2"       => ["/usr/lib64/libSDL2-2.0.so.0", "/usr/lib64/libSDL2.so"],
                    "openal"     => ["/usr/lib64/libopenal.so.1",   "/usr/lib64/libopenal.so"],
                    "libsndfile" => ["/usr/lib64/libsndfile.so.1",  "/usr/lib64/libsndfile.so"],
                    "ruby-devel" => Dir.glob("/usr/include/ruby*").any?,
                    "gcc/g++"    => system("which gcc > /dev/null 2>&1"),
                    }

                pkg_checks.each do |name, check|
                    found = case check
                when String               then File.exist?(check)
                when Array                then check.any? { |p| File.exist?(p) }
                when TrueClass, FalseClass then check
                else false
                end

                if found
                    puts "  #{Colors::SUCCESS}     ✔ #{name}#{Colors::RESET}"
                else
                    puts "  #{Colors::WARNING}     ⚠ #{name} — może brakować#{Colors::RESET}"
                    missing << name
                end
            end

            puts

            unless missing.empty?
                puts "  #{Colors::WARNING}#{Colors::BOLD}  Zainstaluj brakujące pakiety systemowe:#{Colors::RESET}"
                puts "  #{Colors::SUBTLE}  sudo dnf install -y \\"
                puts "      SDL2-devel openal-soft-devel libsndfile-devel \\"
                puts "      mesa-libGL-devel ruby-devel gcc gcc-c++ make#{Colors::RESET}"
                puts
                print "  #{Colors::WARNING}Kontynuować mimo to? (tak/nie): #{Colors::RESET}"
                answer = $stdin.gets&.strip&.downcase
                unless %w[tak t yes y].include?(answer)
                    puts "  #{Colors::SUBTLE}Anulowano.#{Colors::RESET}"
                    exit 0
                end
                puts
            end
        end

        def create_venv_dirs!
            puts "  #{Colors::ELECTRIC_BLUE}#{Colors::BOLD}  ›#{Colors::RESET}  #{Colors::BRIGHT_WHITE}Tworzę katalogi środowiska…#{Colors::RESET}"
            FileUtils.mkdir_p(GEM_HOME)
            puts "  #{Colors::SUCCESS}     ✔ #{GEM_HOME}#{Colors::RESET}"
            puts
        end

        def install_gosu!
            puts "  #{Colors::ELECTRIC_BLUE}#{Colors::BOLD}  ›#{Colors::RESET}  #{Colors::BRIGHT_WHITE}Instaluję gem Gosu #{GOSU_VERSION}…#{Colors::RESET}"
            puts "  #{Colors::SUBTLE}  (kompilacja natywna, może potrwać chwilę…)#{Colors::RESET}"
            puts

            env = {
                "GEM_HOME"       => GEM_HOME,
                "GEM_PATH"       => GEM_HOME,
                "GEM_SPEC_CACHE" => File.join(GEM_HOME, "specs"),
                }

            cmd = "gem install gosu --version '#{GOSU_VERSION.gsub("~> ", "")}' " \
              "--no-document --user-install 2>&1"

            success = false
            IO.popen(env, cmd) do |io|
                io.each_line do |line|
                    puts "  #{Colors::SUBTLE}  │ #{line.chomp.slice(0, 70)}#{Colors::RESET}"
                    $stdout.flush
                end
                io.close
                success = $?.success?
            end

            unless success
                puts
                puts "  #{Colors::ERROR}#{Colors::BOLD}  ✘  Instalacja Gosu nie powiodła się!#{Colors::RESET}"
                puts
                puts "  #{Colors::SUBTLE}  Spróbuj ręcznie:#{Colors::RESET}"
                puts "  #{Colors::BOLD}#{Colors::ELECTRIC_BLUE}    GEM_HOME=#{GEM_HOME} gem install gosu#{Colors::RESET}"
                puts
                puts "  #{Colors::SUBTLE}  Wymagane pakiety na Fedorze:#{Colors::RESET}"
                puts "  #{Colors::SUBTLE}    sudo dnf install -y SDL2-devel openal-soft-devel \\"
                puts "        libsndfile-devel mesa-libGL-devel ruby-devel gcc gcc-c++ make#{Colors::RESET}"
                exit 1
            end
        end

        # ── Game launch ──────────────────────────────────────────────────────────

        def launch_game!
            puts "  #{Colors::VIVID_MAGENTA}#{Colors::BOLD}  ⚡  Uruchamiam LegendaryOS Phoenix Runner…#{Colors::RESET}"
            puts

            env_gem_path = [GEM_HOME, ENV["GEM_PATH"]].compact.reject(&:empty?).join(":")

            exec(
                { "GEM_PATH" => env_gem_path, "GEM_HOME" => GEM_HOME },
                RbConfig.ruby, GAME_ENTRY
            )
        rescue Errno::ENOENT => e
            fail_and_exit("Nie można uruchomić gry: #{e.message}")
        end

        def fail_and_exit(msg)
            puts "  #{Colors::ERROR}#{Colors::BOLD}✘  #{msg}#{Colors::RESET}"
            puts
            exit 1
        end
    end
end
end
