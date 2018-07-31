module PhcStringFormat
  #
  # Parser for parsing PHC-string-format.
  #
  class PhcString
    def self.parse(string, hint: {})
      string ||= ''
      elements = string.split(/\$/, 6)
      elements.shift
      id = elements.shift
      version = elements.shift if (elements.first || '').start_with?('v=')
      params = elements.shift if (elements.first || '').include?('=')
      salt = elements.shift
      hash = elements.shift
      begin
        PhcString.new(id, version, params, salt, hash, hint)
      rescue ArgumentError
        raise ParseError
      end
    end

    def self.create(id:, version: nil, params: nil, salt: nil, hash: nil, hint: {})
      PhcString.new(
        id,
        ("v=#{version}" if version),
        (params.map { |entry| entry.join '=' }.join(',') if params),
        hint.dig(:salt, :encoding) == '7bit' ? salt : B64.encode(salt),
        B64.encode(hash),
        hint
      )
    end

    def initialize(id, version_string, params_string, encoded_salt, encoded_hash, hint)
      validates(message: 'id is non-compliant') { id && id =~ /\A[a-z0-9-]{1,32}\z/ }
      validates(message: 'version is non-compliant') { !version_string || version_string =~ /\Av=\d+\z/ }
      validates(message: 'parameters is non-compliant') do
        !params_string || params_string.split(',').all? \
          { |param| param =~ %r{\A[a-z0-9-]{1,32}=[a-zA-Z0-9/+.-]+\z} }
      end
      validates(message: 'encoded salt is non-compliant') \
        { !encoded_salt || encoded_salt =~ %r{\A[a-zA-Z0-9/+.-]+\z} }
      validates(message: 'encoded hash is non-compliant') \
        { !encoded_hash || encoded_hash =~ %r{\A[a-zA-Z0-9\/+]+\z} }
      validates(message: 'hash needs salt') \
        { !((!encoded_salt || encoded_salt.empty?) && !(!encoded_hash || encoded_hash.empty?)) }

      @id = id
      @version_string = version_string
      @params_string = params_string
      @encoded_salt = encoded_salt
      @encoded_hash = encoded_hash
      @hint = hint
    end

    def to_s
      '$' + [
        @id,
        @version_string,
        @params_string,
        @encoded_salt,
        @encoded_hash
      ].reject { |element| !element || element.empty? }.join('$')
    end

    def to_h(pick = nil)
      pick ||= %i[id version params salt hash]
      {
        id: (@id if pick.include?(:id)),
        version: (parse_version(@version_string) if pick.include?(:version)),
        params: (parse_params(@params_string) if pick.include?(:params)),
        salt:
          if pick.include?(:salt)
            @hint.dig(:salt, :encoding) == '7bit' ? e : B64.decode(@encoded_salt)
          end,
        hash: (B64.decode(@encoded_hash) if pick.include?(:hash))
      }.select { |_, value| value }
    end

    private

    def validates(message:)
      raise ArgumentError, message unless yield
    end

    def parse_version(version_string)
      parse_params(version_string)['v']
    end

    def parse_params(params_string)
      mapper = ->(param) { param.split '=' }
      reducer = lambda do |param, params|
        name, value = param
        params[name] = value =~ /\A-?\d+(.\d+)?\Z/ ? value.to_i : value
      end
      params_string ||= ''
      params_string.split(/,/).map(&mapper).each_with_object({}, &reducer)
    end
  end

  class ParseError < StandardError; end
end
