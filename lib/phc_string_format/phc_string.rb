module PhcStringFormat
  #
  # Parser for parsing PHC-string-format.
  #
  class PhcString
    include Validations

    def self.parse(string)
      string ||= ''
      PhcString.new(*split(string))
    rescue StandardError => exception
      raise ParseError, exception.message
    end

    # :reek:DuplicateMethodCall { allow_calls: ['elements.shift', 'elements.first'] }
    def self.split(string)
      elements = string.split(/\$/, 6)
      elements.shift
      [
        elements.shift,
        (elements.shift if (elements.first || '').start_with?('v=')),
        (elements.shift if (elements.first || '').include?('=')),
        elements.shift,
        elements.shift
      ]
    end

    def self.create(id:, version: nil, params: nil, salt: nil, hash: nil, hint: {})
      PhcString.new \
        id,
        (Parameters.to_s(v: version) if version),
        (Parameters.to_s(params) if params),
        hint.dig(:salt, :encoding) == '7bit' ? salt : B64.encode(salt),
        B64.encode(hash)
    end

    private_class_method :split

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
      format: { with: %r{\A[a-zA-Z0-9/+.-]*\z} }
    validates \
      :@encoded_hash,
      message: 'encoded hash is non-compliant',
      allow_nil: true,
      format: { with: %r{\A[a-zA-Z0-9/+]*\z} }
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
      ].compact.join('$')
    end

    def to_h(pick: nil, hint: {})
      pick ||= %i[id version params salt hash]
      {
        id: (@id if pick.include?(:id)),
        version: (Parameters.to_h(@version_string)['v'] if pick.include?(:version)),
        params: (Parameters.to_h(@params_string) if pick.include?(:params)),
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
      @encoded_salt || !@encoded_hash
    end

    #
    # PHC string parameters
    #
    module Parameters
      def self.to_s(params)
        params ||= {}
        params.map { |param| param.join '=' }.join(',')
      end

      def self.to_h(params_string)
        params_string ||= ''
        params_string
          .split(/,/)
          .map { |param| param.split '=' }
          .map { |name, value| [name, value =~ /\A-?\d+(.\d+)?\Z/ ? value.to_i : value] }
          .to_h
      end
    end
  end

  #
  # This exception is raised if a parser error occurs.
  #
  class ParseError < StandardError; end
end
