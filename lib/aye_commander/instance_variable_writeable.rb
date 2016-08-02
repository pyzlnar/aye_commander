module AyeCommander
  # Method missing to write instance_variables
  module InstanceVariableWriteable
    def method_missing(name, *args)
      if (match = /(.*)=\z/.match(name))
        var_name = "@#{match[1]}"
        instance_variable_set var_name, args.first
        self.class.uses match[1]
      else
        super
      end
    rescue NameError
      super
    end

    private

    def respond_to_missing?(name, *args)
      /=\z/ =~ name ? true : super
    end
  end
end
