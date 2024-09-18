# frozen_string_literal: true

require "boring-service/hooks"
require 'boring-service/parameter'

# Provides a standard implementation for a service-object approach to abstracting large methods.
#
# @example Defining and invoking a method object
#   class ComplexCalculation < BoringService
#     parameter :start_number, Integer
#     parameter :end_number, Integer, default: 2
#
#     def call
#       @magic_number = 42
#       perform_complex_calculation
#     end
#
#     private
#
#     def perform_complex_calculation
#       start_number + second_number + @magic_number
#     end
#   end
#
#   ComplexCalculation.call(start_number: 1, end_number: 3) #=> 46
#   ComplexCalculation.call(start_number: 1) #=> 45
#   ComplexCalculation.call(end_number: 3) #=> raise BoringService::UnknownParameter
#
#   calculation = ComplexCalculation.new(end_number: 3)
#   calculation.start_number = 1
#   calculation.call # => 46
#
#   calculation.end_number = 2
#   calculation.call # => 45
#
class BoringService
  ParameterError = Class.new(::ArgumentError)
  ParameterRequired = Class.new(ParameterError)
  InvalidParameterValue = Class.new(ParameterError)
  UnknownParameter = Class.new(ParameterError)

  include Hooks

  class << self
    # Calls the BoringService with the given arguments.
    #
    # @param **args [Hash{Symbol => Object}] arguments to pass to the method
    # @return [Object] return value of the method object
    def call(**args)
      new(**args).run
    end

    protected

    # Defines a parameter for the service object.
    #
    # Parameters are also inherited from superclasses and can be redefined (overwritten) in subclasses.
    #
    # @param name [Symbol] name of the parameter
    # @param type [Class, Array, #===] type of the parameter. Can be a Class, an Array of classes, a Proc, or anything
    # that defines a meaningful `===` method.
    # @param **options [Hash] extra options for the parameter
    # @option **options [Object, #call] :default default value if the parameter is not passed. If the default implements
    #   `#call`, it gets called once in the context of the method object instance when it is instantiated.
    #
    # @return [void]
    def parameter(name, type = BasicObject, **options)
      arg = BoringService::Parameter.new(name, type, options)
      parameters.delete(arg)
      parameters << arg

      define_method("#{name}=") do |value|
        raise InvalidParameterValue, "Expected a #{type} for #{name}, #{value.class} received" unless arg.acceptable?(value)
        instance_variable_set("@#{name}", value)
      end

      define_method("#{name}?") do
        !public_send(name).nil?
      end

      attr_reader name
    end

    private

    # @return [Set]
    def superclass_parameters
      if superclass < BoringService
        superclass.send(:parameters)
      else
        Set.new
      end
    end

    # @return [Set]
    def parameters
      @parameters ||= Set.new(superclass_parameters)
    end
  end

  # @param **args [Hash{Symbol => Object}] arguments to set on the method object
  def initialize(**args)
    self.class.send(:parameters).freeze

    args.each do |k, v|
      method = "#{k}="
      raise UnknownParameter, "Parameter #{k} unknown" unless respond_to?(method)
      public_send(method, v)
    end

    self.class.send(:parameters)
      .reject { |p| args.keys.map(&:to_sym).include?(p.name) }
      .select(&:default?)
      .each { |p| public_send("#{p.name}=", p.default_in(self)) }
  end

  def run
    assert_required_arguments!
    run_before_hooks
    call
  end

  # Calls the method object with the parameters currently set.
  # @raise [ArgumentError] if any required parameter is missing
  # @return [Object] the return value result of the method invokation
  def call
    # This method is expected to be overridden. If it isn't, this error will be raised.
    raise NotImplementedError, 'Implementation missing. Please use `def call; end` to define method body'
  end

  private

  # @raise [ParameterRequired]
  def assert_required_arguments!
    missing_params =
      self.class.send(:parameters)
        .select { |p| !p.default? && !public_send("#{p.name}?") }
        .map(&:name)

    unless missing_params.empty?
      raise ParameterRequired, "Missing required arguments: #{missing_params.join(', ')}"
    end
  end
end
