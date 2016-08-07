module AyeCommander
  # This module contains mostly methods related to method missing and instance
  # variables
  module Ivar
    # Class Methods used when a reader is not defined
    module ClassMethods
      # Helps decide whether to add using uses or just the reader
      def define_missing_reader(reader)
        respond_to?(:uses) ? uses(reader) : attr_reader(reader)
      end
    end

    # Helps a command and result repond to read methods of instance variables
    module Readable
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
        instance_variable_defined?("@#{name}") || super
      rescue NameError
        super
      end
    end

    # Method missing to write instance_variables
    module Writeable
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
end
