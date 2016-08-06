module AyeCommander
  # This is the meat of AyeComander, what you will include in your commands.
  module Command
    def self.included(includer)
      includer.extend ClassMethods
    end

    # Class Methods to be extended to the includer
    module ClassMethods
      include Limitable::ClassMethods
      include Statusable::ClassMethods
      include Resultable::ClassMethods

      def call(skip_cleanup: false, **args)
        i = new(args)
        validate_arguments(args)
        i.call
        skip_cleanup ? result(i.to_hash) : result(i.to_result_hash)
      end
    end

    include Statusable
    include Inspectable
    include IvarReadable
    include IvarWriteable

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
