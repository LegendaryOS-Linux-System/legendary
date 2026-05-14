# frozen_string_literal: true

module LegendaryOS
  # ANSI color palette inspired by the LegendaryOS phoenix:
  # Deep purple, vivid magenta, electric blue, cyan, dark navy
  module Colors
    # Reset
    RESET       = "\e[0m"
    BOLD        = "\e[1m"
    DIM         = "\e[2m"
    ITALIC      = "\e[3m"
    UNDERLINE   = "\e[4m"

    # Standard colors (remapped to theme)
    BLACK       = "\e[30m"
    RED         = "\e[31m"
    GREEN       = "\e[32m"
    YELLOW      = "\e[33m"
    BLUE        = "\e[34m"
    MAGENTA     = "\e[35m"
    CYAN        = "\e[36m"
    WHITE       = "\e[37m"

    # Bright variants
    BRIGHT_BLACK   = "\e[90m"
    BRIGHT_RED     = "\e[91m"
    BRIGHT_GREEN   = "\e[92m"
    BRIGHT_YELLOW  = "\e[93m"
    BRIGHT_BLUE    = "\e[94m"
    BRIGHT_MAGENTA = "\e[95m"
    BRIGHT_CYAN    = "\e[96m"
    BRIGHT_WHITE   = "\e[97m"

    # 256-color palette – phoenix logo exact tones
    DEEP_PURPLE    = "\e[38;5;57m"    # #5f00ff deep violet
    ROYAL_PURPLE   = "\e[38;5;93m"    # #8700ff royal purple
    VIVID_MAGENTA  = "\e[38;5;165m"   # #d700ff hot magenta
    PINK_MAGENTA   = "\e[38;5;201m"   # #ff00ff neon pink
    ELECTRIC_BLUE  = "\e[38;5;63m"    # #5f5fff electric blue
    COBALT_BLUE    = "\e[38;5;27m"    # #005fff cobalt
    SKY_CYAN       = "\e[38;5;51m"    # #00ffff bright cyan
    NAVY           = "\e[38;5;18m"    # #000087 navy
    DARK_VIOLET    = "\e[38;5;54m"    # #5f0087 dark violet
    LAVENDER       = "\e[38;5;141m"   # #af87ff lavender
    INDIGO         = "\e[38;5;99m"    # #875fff indigo
    PERIWINKLE     = "\e[38;5;105m"   # #8787ff periwinkle

    # Background accents
    BG_DEEP_PURPLE = "\e[48;5;57m"
    BG_NAVY        = "\e[48;5;18m"
    BG_DARK_VIOLET = "\e[48;5;54m"

    # Semantic aliases for the tool
    PRIMARY   = VIVID_MAGENTA
    SECONDARY = ELECTRIC_BLUE
    ACCENT    = SKY_CYAN
    MUTED     = LAVENDER
    TITLE     = PINK_MAGENTA
    HEADER    = ROYAL_PURPLE
    SUCCESS   = BRIGHT_CYAN
    WARNING   = BRIGHT_YELLOW
    ERROR     = BRIGHT_RED
    INFO      = PERIWINKLE
    LABEL     = INDIGO
    VALUE     = BRIGHT_WHITE
    SUBTLE    = BRIGHT_BLACK

    def self.gradient_line(text, width: nil)
      width ||= text.length
      colors = [DEEP_PURPLE, ROYAL_PURPLE, VIVID_MAGENTA, PINK_MAGENTA,
                ELECTRIC_BLUE, COBALT_BLUE, SKY_CYAN]
      chars = text.chars
      out = +""
      chars.each_with_index do |ch, i|
        color = colors[i * colors.length / [chars.length, 1].max % colors.length]
        out << "#{color}#{ch}"
      end
      out << RESET
      out
    end

    def self.colorize(text, *codes)
      "#{codes.join}#{text}#{RESET}"
    end

    def self.paint(text, color)
      "#{color}#{text}#{RESET}"
    end
  end
end
