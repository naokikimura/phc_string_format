module PhcStringFormat
  #
  # Formatter for stringifying and parsing PHC-string-format.
  #
  module Formatter
    def self.format(**kwargs)
      PhcString.create(**kwargs).to_s
    end

    def self.parse(string, hint: {}, pick: nil)
      PhcString.parse(string).to_h(pick: pick, hint: hint)
    end
  end
end
