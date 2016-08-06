module AyeCommander
  # Method missing to write instance_variables
  module IvarWriteable
    def method_missing(name, *args)
      if name[-1] == '='
        var_name = "@#{name[0...-1]}"
        instance_variable_set var_name, args.first
        self.class.uses name[0...-1]
      else
        super
      end
    rescue NameError
      super
    end

    private

    def respond_to_missing?(name, *args)
      name[-1] == '=' || super
    end
  end
end
