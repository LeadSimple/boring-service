# frozen_string_literal: true

class BoringService
  class Parameter
    def initialize(name, type, options = {})
      invalid_options = options.keys - [:default]
      raise ArgumentError, "Invalid keys: #{invalid_options.inspect}. Valid keys are: :default" \
        unless invalid_options.empty?

      @name = name
      @type = type
      @options = options

      freeze
    end

    attr_reader :name, :type

    def default?
      @options.key?(:default)
    end

    def default
      @options[:default]
    end

    def default_in(context)
      if @options[:default].respond_to?(:call)
        context.instance_exec(&@options[:default])
      else
        @options[:default]
      end
    end

    def acceptable?(value)
      (value.nil? && nullable?) || type === value # rubocop:disable Style/CaseEquality
    end

    def nullable?
      default? && default.nil?
    end
  end
end
