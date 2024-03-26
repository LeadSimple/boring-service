class SimpleService
  module Hooks
    def self.included(base)
      base.class_eval do
        extend ClassMethods
      end
    end

    module ClassMethods
      # Public: Declare hooks to run before the service is called. The before method may be called multiple times, with
      # subsequent calls being appended to the existing before hooks.
      #
      # hooks - Zero or more Symbol method names – the declared method will be called before service invocation.
      # block - An optional block to be executed as a hook. If given, the block is executed after methods corresponding
      #         to any given Symbols.
      #
      # Examples
      #
      #   class MyService < SimpleService
      #     before :set_start_time
      #
      #     before do
      #       puts "started at #{@start_time}"
      #     end
      #
      #     def call
      #       puts "called"
      #     end
      #
      #     private
      #
      #     def set_start_time
      #       @start_time = Time.now
      #     end
      #   end
      #
      # Returns nothing.
      def before(*hooks, &block)
        hooks << block if block
        hooks.each { |hook| before_hooks.push(hook) }
      end

      # Internal: An Array of declared hooks to run before Interactor
      # invocation. The hooks appear in the order in which they will be run.
      #
      # Examples
      #
      #   class MyInteractor
      #     include Interactor
      #
      #     before :set_start_time, :say_hello
      #   end
      #
      #   MyInteractor.before_hooks
      #   # => [:set_start_time, :say_hello]
      #
      # Returns an Array of Symbols and Procs.
      def before_hooks
        @before_hooks ||= []
      end
    end

    private

    # Internal: Run before hooks.
    #
    # Returns nothing.
    def run_before_hooks
      run_hooks(self.class.before_hooks)
    end

    # Internal: Run a colection of hooks. The "run_hooks" method is the common
    # interface by which collections of either before or after hooks are run.
    #
    # hooks - An Array of Symbol and Proc hooks.
    #
    # Returns nothing.
    def run_hooks(hooks)
      hooks.each { |hook| run_hook(hook) }
    end

    # Internal: Run an individual hook. The "run_hook" method is the common
    # interface by which an individual hook is run. If the given hook is a
    # symbol, the method is invoked whether public or private. If the hook is a
    # proc, the proc is evaluated in the context of the current instance.
    #
    # hook - A Symbol or Proc hook.
    # args - Zero or more arguments to be passed as block arguments into the
    #        given block or as arguments into the method described by the given
    #        Symbol method name.
    #
    # Returns nothing.
    def run_hook(hook, *args)
      hook.is_a?(Symbol) ? send(hook, *args) : instance_exec(*args, &hook)
    end
  end
end
