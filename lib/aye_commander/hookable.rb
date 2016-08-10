module AyeCommander
  module Hookable
    # Hooks allow to run something, before, around and after the command runs.
    module ClassMethods
      TYPES = %i(before around after aborted).freeze

      TYPES.each do |kind|
        # Defines .before .around and .after
        # Each simply save the hooks in an array.
        define_method kind do |*args, prepend: false, &block|
          args.push block if block
          if prepend
            hooks[kind].unshift(*args)
          else
            hooks[kind].concat(args)
          end
        end

        # Defines .before_hooks .around_hooks and .after_hooks
        # Public interface in case the user wants to see their defined hooks
        define_method "#{kind}_hooks" do
          hooks[kind]
        end

        # Defines .call_before_hooks .call_around_hooks and .call_after_hooks
        # Calls the hooks one by one
        define_method "call_#{kind}_hooks" do |command|
          prepare_hooks(kind, command).each(&:call)
        end
      end

      private

      # Hash that saves the hooks
      def hooks
        @hooks ||= Hash.new([])
      end

      # Prepares the hooks so they can just be called.
      # Before and after are similar in the sense that they just make all the
      # hooks callable and then call themselves.
      # Arounds on the other hand... they basically wrap themselves in procs so
      # that you can call the proc inside the proc that gives the proc. Quite a
      # headache. Why would you need multiple around blocks in the first place?
      def prepare_hooks(kind, command)
        hooks = callable_hooks(kind, command)
        return hooks unless kind == :around

        around_proc = hooks.reverse.reduce(command) do |callable, hook|
          -> { hook.call(callable) }
        end
        [around_proc]
      end

      # Makes all the hooks callable in the command context
      def callable_hooks(kind, command)
        hooks[kind].map do |hook|
          case hook
          when Symbol
            command.method(hook)
          when Proc
            ->(*args) { command.instance_exec(*args, &hook) }
          when Method
            hook
          end
        end
      end
    end
  end
end
