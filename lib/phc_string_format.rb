require 'phc_string_format/version'
require 'base64'

#
# PHC string format implemented by Ruby
#
#  ```
#  $<id>[$<param>=<value>(,<param>=<value>)*][$<salt>[$<hash>]]
#  ```
#
# See:
# - https://github.com/P-H-C/phc-string-format/blob/master/phc-sf-spec.md
# - https://github.com/P-H-C/phc-string-format/pull/4
#
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

  #
  # Parser for parsing PHC-string-format.
  #
  class PhcString
    @parse_version = ->(version) { @parse_parameters.call(version)['v'] }

    @parse_parameters = lambda do |parameters|
      mapper = ->(param) { param.split '=' }
      reducer = lambda do |param, params|
        name, value = param
        params[name] = value =~ /\A-?\d+(.\d+)?\Z/ ? value.to_i : value
      end
      (parameters || '').split(/,/).map(&mapper).each_with_object({}, &reducer)
    end

    def self.parse(string, hint: {})
      elements = (string || '').split(/\$/, 6)
      elements.shift
      id = elements.shift
      version = @parse_version.call(elements.shift) if (elements.first || '').start_with?('v=')
      params = @parse_parameters.call(elements.shift) if (elements.first || '').include?('=')
      salt = elements.shift
      hash = elements.shift
      PhcString.new(id, version, params, salt, hash, hint)
    end

    def self.create(id:, version: nil, params: {}, salt: '', hash: '', hint: {})
      PhcString.new(
        id,
        ("v=#{version}" if version),
        (params.map { |e| e.join '=' }.join(',') if params),
        hint.dig(:salt, :encoding) == '7bit' ? salt : B64.encode(salt),
        B64.encode(hash),
        hint
      )
    end

    def initialize(id, version, params, salt, hash, hint)
      raise ArgumentError.new, 'id is required' unless id
      raise ArgumentError.new, 'hash needs salt' if (!salt || salt.empty?) && !(!hash || hash.empty?)

      @id = id
      @version = version
      @params = params
      @salt = salt
      @hash = hash
      @hint = hint
    end

    def to_s
      '$' + [@id, @version, @params, @salt, @hash].reject { |e| e.nil? || e.empty? }.join('$')
    end

    def to_h(pick = nil)
      pick ||= %i[id version params salt hash]
      {
        id: (@id if pick.include?(:id)),
        version: (@version if pick.include?(:version)),
        params: (@params if pick.include?(:params)),
        salt: ((@hint.dig(:salt, :encoding) == '7bit' ? e : B64.decode(@salt)) if pick.include?(:salt)),
        hash: (B64.decode(@hash) if pick.include?(:hash))
      }.select { |_, v| v }
    end
  end

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
