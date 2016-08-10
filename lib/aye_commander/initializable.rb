module AyeCommander
  # Handles initialize to instance variable in Command and Result
  module Initializable
    def initialize(**args)
      args.each do |name, value|
        instance_variable_set to_ivar(name), value
      end
    end
  end
end
