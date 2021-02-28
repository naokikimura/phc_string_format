# frozen_string_literal: true

module PhcStringFormat
  #
  # Provides a validation framework to your objects.
  #
  module Validations
    def self.included(klass)
      klass.extend ClassMethods
    end

    #
    # class methods
    #
    module ClassMethods
      def validates(name, **options)
        @validators ||= []
        @validators << lambda { |object|
          value = object.instance_variable_get(name)
          return if options[:allow_nil] && !value

          regex = options.dig(:format, :with)
          raise ArgumentError, options[:message] unless !regex || value =~ regex
        }
      end

      def validate(name, **options)
        @validators ||= []
        @validators << ->(object) { raise ArgumentError, options[:message] unless object.send(name) }
      end

      def do_validate(that)
        @validators.each { |validator| validator.call(that) }
        that
      end
    end
  end
end
