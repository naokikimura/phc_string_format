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
    def self.format(id:, version: nil, params: {}, salt: '', hash: '', hint: {salt: {encoding: 'base64'}})
      raise ArgumentError.new, 'id is required' if id.nil?
      raise ArgumentError.new, 'hash needs salt' if (salt.nil? || salt.empty?) && !(hash.nil? || hash.empty?)

      elements = [
        id,
        ("v=#{version}" if version),
        (params.map{|e| e.join '='}.join(',') if params),
        hint.dig(:salt, :encoding) == '7bit' ? salt : short_strict_encode64(salt),
        short_strict_encode64(hash)
      ]
      "$#{elements.select{|e| !(e.nil? || e.empty?)}.join('$')}"
    end

    def self.parse(string, hint: {salt: {encoding: 'base64'}})
      elements = string.split(/\$/, 6)
      elements.shift
      id = elements.shift
      version = parse_parameter_string(elements.shift)['v'] if (elements.first || '').start_with?('v=')
      params = parse_parameter_string(elements.shift) if (elements.first || '').include?('=')
      salt = hint.dig(:salt, :encoding) == '7bit' ? elements.shift : short_strict_decode64(elements.shift)
      hash = short_strict_decode64(elements.shift)
      {id: id, version: version, params: params, salt: salt, hash: hash}.select {|_,v| v}
    end

    def self.parse_parameter_string(string)
      string.split(/,/).map {|e| e.split '='}.each_with_object({}){|e, h| k, v = e; h[k] = (/\A-?\d+(.\d+)?\Z/.match(v) ? v.to_i : v)}
    end

    def self.short_strict_encode64(bin)
      return nil unless bin
      Base64.strict_encode64(bin).delete('=')
    end

    def self.short_strict_decode64(bin)
      return nil unless bin
      Base64.strict_decode64(bin + '=' * (-bin.size % 4))
    end

    private_class_method :short_strict_encode64, :short_strict_decode64, :parse_parameter_string
  end
end
