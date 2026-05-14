# frozen_string_literal: true

require_relative "../colors"
require_relative "../banner"
require_relative "../system_info"

module LegendaryOS
  module Commands
    class Doctor
      include Colors

      CHECKS = [
        {
          id:      :bootc,
          label:   "bootc binary present",
          desc:    "Required for image-based updates and rollbacks",
          check:   -> { File.exist?("/usr/bin/bootc") },
        },
        {
          id:      :version_toml,
          label:   "LegendaryOS version file",
          desc:    "#{SystemInfo::VERSION_TOML} must exist",
          check:   -> { File.exist?(SystemInfo::VERSION_TOML) },
        },
        {
          id:      :kcm_rc,
          label:   "KCM About distro config",
          desc:    "#{SystemInfo::DISTRO_RC} – KDE about-this-system info",
          check:   -> { File.exist?(SystemInfo::DISTRO_RC) },
          warn:    true,
        },
        {
          id:      :os_release,
          label:   "/etc/os-release present",
          desc:    "Standard Linux distribution identity file",
          check:   -> { File.exist?(SystemInfo::OS_RELEASE) },
        },
        {
          id:      :fedora_release,
          label:   "/etc/fedora-release present",
          desc:    "Fedora-specific release identification",
          check:   -> { File.exist?(SystemInfo::FEDORA_RELEASE) },
          warn:    true,
        },
        {
          id:      :ostree_or_bootc,
          label:   "Immutable root filesystem",
          desc:    "Either ostree or bootc managed root",
          check:   -> {
            File.exist?("/run/ostree-booted") ||
              File.exist?("/usr/bin/bootc") ||
              Dir.exist?("/sysroot/ostree")
          },
        },
        {
          id:      :systemd,
          label:   "systemd running",
          desc:    "PID 1 must be systemd for bootc compatibility",
          check:   -> { File.exist?("/run/systemd/system") },
        },
        {
          id:      :rpm_ostree_or_bootc,
          label:   "Package manager (rpm-ostree or bootc)",
          desc:    "One of rpm-ostree or bootc must be available",
          check:   -> {
            SystemInfo.check_binary("rpm-ostree") ||
              SystemInfo.check_binary("bootc")
          },
        },
        {
          id:      :network,
          label:   "Network connectivity",
          desc:    "Required for pulling container images",
          check:   -> { system("ping -c 1 -W 2 8.8.8.8 > /dev/null 2>&1") },
          warn:    true,
        },
        {
          id:      :root_readonly,
          label:   "/usr read-only or overlay",
          desc:    "Expected on an immutable system",
          check:   -> {
            output = `mount 2>/dev/null | grep -E ' / | /usr '`
            output.include?("ro,") || output.include?(",ro") || output.include?("overlay")
          },
          warn:    true,
        },
      ].freeze

      def run
        Banner.print_banner

        Banner.section("System Health Check — legendary doctor")
        puts

        passed  = 0
        warned  = 0
        failed  = 0

        CHECKS.each do |check|
          result = begin
                     check[:check].call
                   rescue StandardError
                     false
                   end

          icon, color, status_tag = if result
                                       passed += 1
                                       ["✔", Colors::SUCCESS, "  OK  "]
                                     elsif check[:warn]
                                       warned += 1
                                       ["⚠", Colors::WARNING, " WARN "]
                                     else
                                       failed += 1
                                       ["✘", Colors::ERROR, " FAIL "]
                                     end

          bg = result ? Colors::DARK_VIOLET : (check[:warn] ? "" : "")
          tag = "#{color}#{Colors::BOLD}[#{status_tag}]#{Colors::RESET}"
          icon_s = "#{color}#{Colors::BOLD} #{icon}#{Colors::RESET}"
          label  = "#{Colors::BRIGHT_WHITE}#{Colors::BOLD}#{check[:label]}#{Colors::RESET}"
          desc   = "#{Colors::MUTED}#{check[:desc]}#{Colors::RESET}"

          puts "  #{icon_s}  #{tag}  #{label}"
          puts "         #{Colors::SUBTLE}↳ #{desc}#{Colors::RESET}"
          puts
        end

        Banner.separator

        # Summary
        puts
        total = passed + warned + failed
        puts "  #{Colors::BOLD}#{Colors::BRIGHT_WHITE}Summary:#{Colors::RESET}  " \
             "#{Colors::SUCCESS}#{Colors::BOLD}#{passed} passed#{Colors::RESET}  " \
             "#{Colors::WARNING}#{warned} warnings#{Colors::RESET}  " \
             "#{Colors::ERROR}#{failed} failed#{Colors::RESET}  " \
             "#{Colors::SUBTLE}(#{total} total checks)#{Colors::RESET}"
        puts

        if failed == 0 && warned == 0
          puts Colors.paint("  ⚡  Your LegendaryOS installation is in perfect shape!", Colors::VIVID_MAGENTA + Colors::BOLD)
        elsif failed == 0
          puts Colors.paint("  ⚡  System is healthy — #{warned} non-critical item(s) to review.", Colors::WARNING)
        else
          puts Colors.paint("  ✘  #{failed} critical issue(s) detected. Please investigate.", Colors::ERROR + Colors::BOLD)
        end
        puts
      end
    end
  end
end
