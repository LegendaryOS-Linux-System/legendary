require_relative "toml_parser"

module LegendaryOS
  module SystemInfo
    VERSION_TOML     = "/usr/share/LegendaryOS/version.toml"
    DISTRO_RC        = "/etc/xdg/kcm-about-distrorc"
    OS_RELEASE       = "/etc/os-release"
    FEDORA_RELEASE   = "/etc/fedora-release"
    BOOTC_BIN        = "/usr/bin/bootc"

    def self.legendary_os_version
      data = TomlParser.load_file(VERSION_TOML)
      # Sekcja może być [LegendaryOS] (z wielkiej) lub [legendary_os] (stary format)
      los = data["LegendaryOS"] || data["legendary_os"] || {}
      {
        version:      los["version"]      || "unknown",
        release_date: los["release_date"] || "unknown",
        base:         los["base"]         || "Fedora",
        base_version: los["base_version"] || "unknown",
        edition:      los["edition"]      || los["desktop"] || "unknown",
        architecture: los["architecture"] || "x86_64",
        # pola zachowane dla kompatybilności wstecznej
        codename:     los["codename"]     || "",
        variant:      los["variant"]      || "immutable",
        boot_system:  los["boot_system"]  || "bootc",
        build_id:     (data["build"] || {})["build_id"] || "unknown",
        image:        (data["build"] || {})["image"]    || "unknown",
      }
    end

    def self.fedora_version
      if File.exist?(FEDORA_RELEASE)
        File.read(FEDORA_RELEASE).strip
      elsif File.exist?(OS_RELEASE)
        parse_os_release["VERSION_ID"] || "unknown"
      else
        "unknown"
      end
    rescue StandardError
      "unknown"
    end

    def self.os_release
      return {} unless File.exist?(OS_RELEASE)

      parse_os_release
    rescue StandardError
      {}
    end

    def self.kcm_distro_info
      return {} unless File.exist?(DISTRO_RC)

      result = {}
      File.each_line(DISTRO_RC) do |line|
        line = line.strip
        next if line.empty? || line.start_with?("[", "#", ";")

        if (m = line.match(/^([^=]+)\s*=\s*(.*)$/))
          result[m[1].strip] = m[2].strip.gsub(/^["']|["']$/, "")
        end
      end
      result
    rescue StandardError
      {}
    end

    def self.kernel_version
      `uname -r`.strip
    rescue StandardError
      "unknown"
    end

    def self.hostname
      `hostname -f 2>/dev/null || hostname`.strip
    rescue StandardError
      "unknown"
    end

    def self.uptime
      raw = File.read("/proc/uptime").split.first.to_f
      seconds = raw.to_i
      days    = seconds / 86_400
      hours   = (seconds % 86_400) / 3_600
      minutes = (seconds % 3_600) / 60
      parts = []
      parts << "#{days}d"    if days > 0
      parts << "#{hours}h"   if hours > 0
      parts << "#{minutes}m" if minutes > 0
      parts.empty? ? "<1m" : parts.join(" ")
    rescue StandardError
      "unknown"
    end

    def self.architecture
      `uname -m`.strip
    rescue StandardError
      "unknown"
    end

    def self.bootc_status
      return { available: false, status: "bootc not found" } unless File.exist?(BOOTC_BIN)

      raw = `#{BOOTC_BIN} status 2>&1`
      { available: true, raw: raw, exit_code: $?.exitstatus }
    rescue StandardError => e
      { available: false, status: e.message }
    end

    def self.check_binary(name)
      system("which #{name} > /dev/null 2>&1")
    end

    private

    def self.parse_os_release
      result = {}
      File.each_line(OS_RELEASE) do |line|
        line = line.strip
        next if line.empty? || line.start_with?("#")

        if (m = line.match(/^([^=]+)="?([^"]*)"?$/))
          result[m[1]] = m[2]
        end
      end
      result
    end
  end
end
