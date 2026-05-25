module LegendaryOS
  # Minimal TOML parser – handles the subset used in version.toml
  # (sections, string values, integer values, quoted strings)
  module TomlParser
    def self.parse(content)
      result = {}
      current_section = nil

      content.each_line do |raw|
        line = raw.strip
        next if line.empty? || line.start_with?("#")

        # Section header [section] or [section.subsection]
        if (m = line.match(/^\[([^\]]+)\]$/))
          parts = m[1].split(".")
          current_section = parts.reduce(result) do |hash, key|
            hash[key] ||= {}
          end
          next
        end

        # Key = value
        if (m = line.match(/^([^=]+)\s*=\s*(.+)$/))
          key = m[1].strip
          raw_val = m[2].strip

          value = case raw_val
                  when /^"(.*)"$/, /^'(.*)'$/ then Regexp.last_match(1)
                  when /^\d+$/ then raw_val.to_i
                  when /^true$/i then true
                  when /^false$/i then false
                  else raw_val
                  end

          target = current_section || result
          target[key] = value
        end
      end

      result
    end

    def self.load_file(path)
      return {} unless File.exist?(path)

      parse(File.read(path))
    rescue StandardError
      {}
    end
  end
end
