module PhcStringFormat
  #
  # Parser for parsing PHC-string-format.
  #
  class PhcString
    def self.validates(name, **options)
      @validators ||= []
      @validators << lambda { |object|
        value = object.instance_variable_get(name)
        return if options[:allow_nil] && !value
        regex = options.dig(:format, :with)
        raise ArgumentError, options[:message] unless !regex || value =~ regex
      }
    end

    def self.validate(name, **options)
      @validators ||= []
      @validators << ->(object) { raise ArgumentError, options[:message] unless object.send(name) }
    end

    def self.do_validate(that)
      @validators.each { |validator| validator.call(that) }
      that
    end

    private_class_method :validates, :validate

    # :reek:DuplicateMethodCall { allow_calls: ['elements.shift', 'elements.first'] }
    def self.parse(string)
      string ||= ''
      elements = string.split(/\$/, 6)
      elements.shift
      id = elements.shift
      version = elements.shift if (elements.first || '').start_with?('v=')
      params = elements.shift if (elements.first || '').include?('=')
      salt = elements.shift
      hash = elements.shift
      begin
        PhcString.new(id, version, params, salt, hash)
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
        B64.encode(hash)
      )
    end

    validates :@id, message: 'id is non-compliant', format: { with: /\A[a-z0-9-]{1,32}\z/ }
    validates \
      :@version_string,
      message: 'version is non-compliant',
      allow_nil: true,
      format: { with: /\Av=\d+\z/ }
    validate :validate_params_string, message: 'parameters is non-compliant'
    validates \
      :@encoded_salt,
      message: 'encoded salt is non-compliant',
      allow_nil: true,
      format: { with: %r{\A[a-zA-Z0-9/+.-]+\z} }
    validates \
      :@encoded_hash,
      message: 'encoded hash is non-compliant',
      allow_nil: true,
      format: { with: %r{\A[a-zA-Z0-9/+]+\z} }
    validate :validate_salt_and_hash, message: 'hash needs salt'

    def initialize(id, version_string, params_string, encoded_salt, encoded_hash)
      @id = id
      @version_string = version_string
      @params_string = params_string
      @encoded_salt = encoded_salt
      @encoded_hash = encoded_hash

      self.class.do_validate self
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

    def to_h(pick: nil, hint: {})
      pick ||= %i[id version params salt hash]
      {
        id: (@id if pick.include?(:id)),
        version: (parse_version(@version_string) if pick.include?(:version)),
        params: (parse_params(@params_string) if pick.include?(:params)),
        salt:
          if pick.include?(:salt)
            hint.dig(:salt, :encoding) == '7bit' ? @encoded_salt : B64.decode(@encoded_salt)
          end,
        hash: (B64.decode(@encoded_hash) if pick.include?(:hash))
      }.select { |_, value| value }
    end

    def ==(other)
      instance_variable_values = other.instance_variables.map { |name| other.instance_variable_get(name) }
      instance_variable_values == instance_variables.map { |name| instance_variable_get(name) }
    end

    private

    def validate_params_string
      !@params_string || !@params_string.empty? && @params_string.split(',').all? \
        { |param| param =~ %r{\A[a-z0-9-]{1,32}=[a-zA-Z0-9/+.-]+\z} }
    end

    def validate_salt_and_hash
      !((!@encoded_salt || @encoded_salt.empty?) && !(!@encoded_hash || @encoded_hash.empty?))
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

  #
  # This exception is raised if a parser error occurs.
  #
  class ParseError < StandardError; end
end
