module AyeCommander
  # This is the meat of AyeComander, what you will include in your commands.
  module Command
    def self.included(includer)
      includer.extend ClassMethods
    end

    # Class Methods to be extended to the includer
    module ClassMethods
      include Abortable::ClassMethods
      include IvarReadable::ClassMethods
      include Limitable::ClassMethods
      include Resultable::ClassMethods
      include Status::ClassMethods

      def call(skip_cleanup: false, **args)
        command = new(args)
        validate_arguments(args)
        call_being_abortable(command)
        skip_cleanup ? result(command.to_hash) : result(command.to_result_hash)
      end
    end

    include Abortable
    include Inspectable
    include IvarReadable
    include IvarWriteable
    include Status::Readable
    include Status::Writeable

    # Initializes the command with the correct setup
    #
    # Status is set to the first of the suceeds status, which in most scenarios
    # will be :success
    #
    # Argument validation is then done to ensure that the received and required
    # arguments have no inconsistencies.
    def initialize(**args)
      @status = self.class.succeeds.first

      args.each do |name, value|
        instance_variable_set "@#{name}", value
      end
    end

    def call
    end
  end
end
