require "phc_string_format/version"
require "base64"

#
# PHC string format implemented by Ruby
#
#  ```
#  $<id>[$<param>=<value>(,<param>=<value>)*][$<salt>[$<hash>]]
#  ```
#
module PhcStringFormat

  module Formatter

    #
    def self.format(id:, params: {}, salt: '', hash: '')
      raise ArgumentError.new, 'id is required' if id.nil?
      raise ArgumentError.new, 'hash needs salt' if (salt.nil? || salt.empty?) && !(hash.nil? || hash.empty?)

      elements = [
        id,
        params.entries.map { |k, v| "#{k}=#{v}" }.join(','),
        short_strict_encode64(salt),
        short_strict_encode64(hash)
      ]
      "$#{elements.select { |e| !(e.nil? || e.empty?) } .join('$')}"
    end

    #
    def self.parse(string)
      elements = string.split('$')
      elements.shift
      id = elements.shift
      params = elements.shift.split(',').map {|e| e.split('=')}.reduce({}) {|h, e| k, v = e; h[k]=v; h}
      salt = short_strict_decode64(elements.shift)
      hash = short_strict_decode64(elements.shift)
      {id: id, params: params, salt: salt, hash: hash }
    end

    def self.short_strict_encode64(bin)
      return nil unless bin
      Base64.strict_encode64(bin).delete('=')
    end

    def self.short_strict_decode64(bin)
      return nil unless bin
      Base64.strict_decode64(bin + '=' * (-bin.size % 4))
    end

    private_class_method :short_strict_encode64, :short_strict_decode64

  end

end
