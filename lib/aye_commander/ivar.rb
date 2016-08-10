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

      # Transforms the received name to instance variable form
      def to_ivar(name)
        name[0] == '@' ? name.to_sym : "@#{name}".to_sym
      end

      # Transforms the received name to normal variable form
      def to_nvar(name)
        name[0] == '@' ? name[1..-1].to_sym : name.to_sym
      end
    end

    # Helps a command and result repond to read methods of instance variables
    module Readable
      def method_missing(name, *args)
        var_name = to_ivar(name)
        if instance_variable_defined? var_name
          self.class.define_missing_reader(name)
          instance_variable_get var_name
        else
          super
        end
      rescue NameError
        super
      end

      # Removes the received instance variable name
      def remove!(name)
        remove_instance_variable to_ivar(name)
      end

      # Transforms the received name to instance variable form
      def to_ivar(name)
        self.class.to_ivar(name)
      end

      # Transforms the received name to normal variable form
      def to_nvar(name)
        self.class.to_nvar(name)
      end

      private

      def respond_to_missing?(name, *args)
        instance_variable_defined?(to_ivar(name)) || super
      rescue NameError
        super
      end
    end

    # Method missing to write instance_variables
    module Writeable
      def method_missing(name, *args)
        if name[-1] == '='
          var_name = to_ivar(name[0...-1])
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
