module AyeCommander
  # Hooks are available for all commands.
  # They allow you to run specific parts of code before, around, after the
  # command is called or when if the command was aborted
  module Hookable
    # All hook functionality is defined at a class level, but runs at instance
    # level
    module ClassMethods
      TYPES = %i[before around after aborted].freeze

      TYPES.each do |kind|
        # Defines .before .around .after and .aborted
        # Saves the received argument into their own array
        #
        # Options
        # prepend: Makes it so that the received args are pushed to the front of
        #          the hook array instead of the end.
        define_method kind do |*args, prepend: false, &block|
          args.push block if block
          if prepend
            hooks[kind] = args + hooks[kind]
          else
            hooks[kind] += args
          end
        end

        # Defines .before_hooks .around_hooks .after_hooks and .aborted_hooks
        # Public interface in case the user wants to see their defined hooks
        define_method "#{kind}_hooks" do
          hooks[kind]
        end

        # Defines .call_before_hooks .call_around_hooks .call_after_hooks and
        # .call_aborted_hooks
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
      # Before after and around hooks are similar in the sense that they just
      # need to make all the received hooks callable and then they call
      # themselves.
      #
      # Arounds on the other hand... they basically wrap themselves in procs so
      # that you can call the proc inside the proc that gives the proc.
      # Quite a headache.
      # Why would you need multiple around blocks in the first place?
      def prepare_hooks(kind, command)
        hooks = callable_hooks(kind, command)
        return hooks unless kind == :around

        around_proc = hooks.reverse.reduce(command) do |callable, hook|
          -> { hook.call(callable) }
        end
        [around_proc]
      end

      # Makes all the saved hooks callable in the command context
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
