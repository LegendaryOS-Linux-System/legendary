require_relative "colors"
require_relative "banner"
require_relative "system_info"
require_relative "commands/status"
require_relative "commands/doctor"
require_relative "commands/info"
require_relative "commands/help"
require_relative "commands/update"
require_relative "commands/build"
require_relative "commands/game"
require_relative "commands/motd"
require_relative "commands/community"

module LegendaryOS
  VERSION = "0.0.1"

  class CLI
    include Colors

    def initialize(argv)
      @argv    = argv
      @command = argv[0]&.downcase&.strip
      @args    = argv[1..]
    end

    def run
      case @command
      when "status"
        Commands::Status.new.run
      when "doctor"
        Commands::Doctor.new.run
      when "info"
        Commands::Info.new.run
      when "update"
        Commands::Update.new(@args).run
      when "build"
        Commands::Build.new(@args).run
      when "game"
        Commands::Game.new.run
      when "on"
        handle_on
      when "off"
        handle_off
      when "community"
        Commands::Community.new.run
      when "help", "--help", "-h"
        Commands::Help.new.run(@args&.first)
      when "version", "--version", "-v"
        print_version
      when nil
        Commands::Help.new.run
      else
        unknown_command
      end
    end

    private

    def handle_on
      sub = @args&.first&.downcase&.strip
      case sub
      when "motd"
        Commands::Motd.new.enable
      when nil
        puts "  #{Colors::ERROR}#{Colors::BOLD}✘  Podaj co chcesz włączyć, np. #{Colors::BRIGHT_WHITE}legendary on motd#{Colors::RESET}"
        puts
        exit 1
      else
        puts "  #{Colors::ERROR}#{Colors::BOLD}✘  Nieznana opcja: '#{sub}'#{Colors::RESET}"
        puts
        exit 1
      end
    end

    def handle_off
      sub = @args&.first&.downcase&.strip
      case sub
      when "motd"
        Commands::Motd.new.disable
      when nil
        puts "  #{Colors::ERROR}#{Colors::BOLD}✘  Podaj co chcesz wyłączyć, np. #{Colors::BRIGHT_WHITE}legendary off motd#{Colors::RESET}"
        puts
        exit 1
      else
        puts "  #{Colors::ERROR}#{Colors::BOLD}✘  Nieznana opcja: '#{sub}'#{Colors::RESET}"
        puts
        exit 1
      end
    end

    def print_version
      puts "#{Colors::VIVID_MAGENTA}#{Colors::BOLD}legendary#{Colors::RESET} " \
           "#{Colors::ELECTRIC_BLUE}v#{VERSION}#{Colors::RESET}  " \
           "#{Colors::SUBTLE}— LegendaryOS CLI#{Colors::RESET}"
    end

    def unknown_command
      puts
      puts "  #{Colors::ERROR}#{Colors::BOLD}✘  Unknown command: #{Colors::BRIGHT_WHITE}'#{@command}'#{Colors::RESET}"
      puts
      puts "  #{Colors::SUBTLE}Run #{Colors::BOLD}#{Colors::VIVID_MAGENTA}legendary help#{Colors::RESET}#{Colors::SUBTLE} to see available commands.#{Colors::RESET}"
      puts
      exit 1
    end
  end
end
