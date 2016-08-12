module AyeCommander
  # This module handles initialization of both a Command and a Result
  module Initializable
    # Initializes the command or Result with the correct setup
    #
    # When a command, the status is set based on the first succeeds saved in the
    # class. In most cases this will be :success
    #
    # When a result, the status is sent in the initialization so it is in theory
    # possible to have a result without a status, though not through this gem.
    def initialize(**args)
      @status = self.class.succeeds.first if self.class.respond_to?(:succeeds)
      args.each do |name, value|
        instance_variable_set to_ivar(name), value
      end
    end
  end
end
