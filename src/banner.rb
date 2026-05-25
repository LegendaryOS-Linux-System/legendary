require_relative "colors"

module LegendaryOS
  module Banner
    include Colors

    PHOENIX_ART = <<~'ART'
          ░░░░░       ░░░░░
         ░░░░░░░░   ░░░░░░░░
        ░░░░░░░░░░░░░░░░░░░░░
       ░░░░░░░░░░░░░░░░░░░░░░░
      ░░░░░░░░░ ░░░░░ ░░░░░░░░░
       ░░░░░░░   ███   ░░░░░░░
         ░░░░░  █████  ░░░░░
          ░░░░  ██▀██  ░░░░
           ░░░░  ▀▀▀  ░░░░
            ░░░░░░░░░░░░░
    ART

    LOGO_LINES = [
      " ██╗     ███████╗ ██████╗ ███████╗███╗   ██╗██████╗  █████╗ ██████╗ ██╗   ██╗",
      " ██║     ██╔════╝██╔════╝ ██╔════╝████╗  ██║██╔══██╗██╔══██╗██╔══██╗╚██╗ ██╔╝",
      " ██║     █████╗  ██║  ███╗█████╗  ██╔██╗ ██║██║  ██║███████║██████╔╝ ╚████╔╝ ",
      " ██║     ██╔══╝  ██║   ██║██╔══╝  ██║╚██╗██║██║  ██║██╔══██║██╔══██╗  ╚██╔╝  ",
      " ███████╗███████╗╚██████╔╝███████╗██║ ╚████║██████╔╝██║  ██║██║  ██║   ██║   ",
      " ╚══════╝╚══════╝ ╚═════╝ ╚══════╝╚═╝  ╚═══╝╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝  ",
    ].freeze

    OS_LINES = [
      "  ██████╗ ███████╗",
      " ██╔═══██╗██╔════╝",
      " ██║   ██║███████╗",
      " ██║   ██║╚════██║",
      " ╚██████╔╝███████║",
      "  ╚═════╝ ╚══════╝",
    ].freeze

    GRADIENT = [
      Colors::DEEP_PURPLE,
      Colors::ROYAL_PURPLE,
      Colors::VIVID_MAGENTA,
      Colors::PINK_MAGENTA,
      Colors::ELECTRIC_BLUE,
      Colors::COBALT_BLUE,
    ].freeze

    def self.print_banner
      puts
      LOGO_LINES.each_with_index do |line, i|
        color = GRADIENT[i % GRADIENT.length]
        os_part = OS_LINES[i] || ""
        os_color = [Colors::ELECTRIC_BLUE, Colors::COBALT_BLUE, Colors::SKY_CYAN,
                    Colors::PERIWINKLE, Colors::ELECTRIC_BLUE, Colors::COBALT_BLUE][i % 6]
        print "#{color}#{line}#{Colors::RESET}"
        print "#{os_color}#{os_part}#{Colors::RESET}"
        puts
      end

      tagline = "  ⚡  The Legendary Immutable Linux  •  Powered by Fedora & bootc  ⚡"
      puts
      puts Colors.gradient_line(tagline)
      puts Colors.paint("  " + "─" * 78, Colors::DARK_VIOLET)
      puts
    end

    def self.print_mini_banner
      line1 = "#{Colors::VIVID_MAGENTA}#{Colors::BOLD}⚡ LEGENDARY#{Colors::RESET}"
      line2 = "#{Colors::ELECTRIC_BLUE}OS#{Colors::RESET}"
      puts "  #{line1}#{line2}  #{Colors.paint("v#{LegendaryOS::VERSION}", Colors::MUTED)}"
      puts Colors.paint("  " + "─" * 42, Colors::DARK_VIOLET)
      puts
    end

    def self.section(title)
      bar = Colors.paint("  ┌─", Colors::ROYAL_PURPLE)
      label = "#{Colors::BOLD}#{Colors::PINK_MAGENTA} #{title.upcase} #{Colors::RESET}"
      right = Colors.paint("─" * [40 - title.length, 2].max + "┐", Colors::ROYAL_PURPLE)
      puts "#{bar}#{label}#{right}"
    end

    def self.section_end
      puts Colors.paint("  └" + "─" * 50 + "┘", Colors::ROYAL_PURPLE)
      puts
    end

    def self.kv(key, value, key_color: Colors::LABEL, val_color: Colors::VALUE)
      k = "#{key_color}#{Colors::BOLD}  │  %-22s#{Colors::RESET}" % "#{key}:"
      v = "#{val_color}#{value}#{Colors::RESET}"
      puts "#{k}#{v}"
    end

    def self.separator
      puts Colors.paint("  " + "━" * 78, Colors::DARK_VIOLET)
    end

    def self.spacer
      puts
    end

    def self.dot(color = Colors::VIVID_MAGENTA)
      "#{color}●#{Colors::RESET}"
    end
  end
end
