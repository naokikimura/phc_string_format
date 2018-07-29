require 'base64'

module PhcStringFormat
  #
  # Implementation of B64
  #
  # See:
  # - https://github.com/P-H-C/phc-string-format/blob/master/phc-sf-spec.md#b64
  #
  module B64
    def self.encode(bin)
      return nil unless bin
      Base64.strict_encode64(bin).delete('=')
    end

    def self.decode(bin)
      return nil unless bin
      Base64.strict_decode64(bin + '=' * (-bin.size % 4))
    end
  end
end
