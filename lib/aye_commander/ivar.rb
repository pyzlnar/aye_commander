module AyeCommander
  # This module contains mostly methods related to method missing and instance
  # variables
  module Ivar
    AT = '@'.freeze
    EQ = '='.freeze

    # Instance variable related class methods
    module ClassMethods
      # Adds the received reader to the class.
      # It prefers using 'uses' it available (command), but will use attr_reader
      # if it isn't (result).
      def define_missing_reader(reader)
        respond_to?(:uses) ? uses(reader) : attr_reader(reader)
      end

      # Transforms the received name to instance variable form
      # Eg: command -> @command
      def to_ivar(name)
        name[0] == at ? name.to_sym : "@#{name}".to_sym
      end

      # Transforms the received name to normal variable form
      # Eg: @command -> command
      def to_nvar(name)
        name[0] == at ? name[1..-1].to_sym : name.to_sym
      end

      def at
        ::AyeCommander::Ivar::AT
      end

      def eq
        ::AyeCommander::Ivar::EQ
      end
    end

    # Helps a command and result respond to read methods of instance variables
    # This functionality is divided into two different modules since commander
    # includes both, but result only includes Readable
    module Readable
      # A command will only respond to a read instance variable if it receives
      # a valid instance variable name that is already defined within the
      # command or result.
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

      # This helps remove an instance variable name from the current command.
      # Consider using the .returns method instead.
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

    # Helps a command respond to methods that would be writers
    module Writeable
      # Any method that ends with an equal sign will be able to be handled by
      # this method missing.
      def method_missing(name, *args)
        if name[-1] == self.class.eq
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
        name[-1] == self.class.eq || super
      end
    end
  end
end
