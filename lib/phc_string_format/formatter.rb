module PhcStringFormat
  #
  # Formatter for stringifying and parsing PHC-string-format.
  #
  module Formatter
    def self.format(**kwargs)
      PhcString.create(kwargs).to_s
    end

    def self.parse(string, hint: {}, pick: nil)
      PhcString.parse(string, hint: hint).to_h(pick)
    end
  end
end
