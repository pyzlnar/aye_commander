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
      include Resultable

      def call(**args)
        i = new(args)
        i.call
        command_result(i)
      end
    end

    include Statusable
    include Inspectable

    # Initializes the command with the correct setup
    #
    # Status is set to the first of the suceeds status, which in most scenarios
    # will be :success
    #
    # Argument validation is then done to ensure that the received and required
    # arguments have no inconsistencies.
    def initialize(**args)
      @status = self.class.succeeds.first

      options = { requires: self.class.requires, receives: self.class.receives }
      Limitable.validate_arguments(args, options)

      args.each do |name, value|
        instance_variable_set "@#{name}", value
      end
    end

    def call
    end

    def method_missing(name, *args)
      instance_variable_get "@#{name}" || super
    end

    def respond_to_missing?(name, *args)
      instance_variable_defined?("@#{name}") || super
    end
  end
end
