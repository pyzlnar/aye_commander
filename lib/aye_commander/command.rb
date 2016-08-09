module AyeCommander
  # This is the meat of AyeComander, what you will include in your commands.
  module Command
    def self.included(includer)
      includer.extend ClassMethods
    end

    # Class Methods to be extended to the includer
    module ClassMethods
      include Abortable::ClassMethods
      include Hookable::ClassMethods
      include Ivar::ClassMethods
      include Limitable::ClassMethods
      include Resultable::ClassMethods
      include Status::ClassMethods

      def call(skip_cleanup: false, **args)
        command = new(args)
        validate_arguments(args)
        abortable do
          call_before_hooks(command)
          around_hooks.any? ? call_around_hooks(command) : command.call
          call_after_hooks(command)
        end
        result(command, skip_cleanup)
      end
    end

    include Abortable
    include Initializable
    include Inspectable
    include Ivar::Readable
    include Ivar::Writeable
    include Status::Readable
    include Status::Writeable

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
