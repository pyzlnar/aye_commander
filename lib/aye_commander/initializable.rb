module AyeCommander
  module Initializable
    def initialize(**args)
      args.each do |name, value|
        ivn = name[0] == '@' ? name : "@#{name}"
        instance_variable_set ivn, value
      end
    end
  end
end
