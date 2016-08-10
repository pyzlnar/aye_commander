module AyeCommander
  # This is the meat of AyeComander, what you will include in your commands.
  module Command
    include Abortable
    include Initializable
    include Inspectable
    include Ivar::Readable
    include Ivar::Writeable
    include Status::Readable
    include Status::Writeable

    # Class Methods to be extended to the includer
    module ClassMethods
      include Abortable::ClassMethods
      include Hookable::ClassMethods
      include Ivar::ClassMethods
      include Limitable::ClassMethods
      include Resultable::ClassMethods
      include Status::ClassMethods

      # This method is what the user calls to run their command
      def call(skip_cleanup: false, **args)
        command = new(args)
        validate_arguments(args)
        aborted = abortable do
          call_before_hooks(command)
          around_hooks.any? ? call_around_hooks(command) : command.call
          call_after_hooks(command)
        end
        abortable { call_aborted_hooks(command) } if aborted
        result(command, skip_cleanup)
      end

      # This ensures that class methods are extended when Command is included
      def included(includer)
        super
        includer.extend ClassMethods
      end
    end

    extend ClassMethods

    # Initializes the command with the correct setup
    #
    # Status is set to the first of the suceeds status, which in most scenarios
    # will be :success
    def initialize(**args)
      super status: self.class.succeeds.first, **args
    end

    # Empty call so all commands have one
    def call
    end
  end
end
