module AyeCommander
  # Helps a command and result repond to read methods of instance variables
  module IvarReadable
    # Class Methods
    module ClassMethods
      # Helps decide whether to add using uses or just the reader
      def define_missing_reader(reader)
        respond_to?(:uses) ? uses(reader) : attr_reader(reader)
      end
    end

    def method_missing(name, *args)
      var_name = "@#{name}"
      if instance_variable_defined? var_name
        self.class.define_missing_reader(name)
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
