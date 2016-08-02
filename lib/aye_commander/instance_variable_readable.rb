module AyeCommander
  # Helps a command and result repond to read methods of instance variables
  module InstanceVariableReadable
    def method_missing(name, *args)
      var_name = "@#{name}"
      if instance_variable_defined? var_name
        if self.class.respond_to? :uses
          self.class.uses name
        else
          self.class.class_eval { attr_reader name }
        end
        instance_variable_get var_name
      else
        super
      end
    rescue NameError
      super
    end

    private

    def respond_to_missing?(name, *args)
      var_name = "@#{name}"
      if instance_variable_defined? var_name
        true
      else
        super
      end
    rescue NameError
      super
    end
  end
end
