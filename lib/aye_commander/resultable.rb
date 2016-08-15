module AyeCommander
  # This module helps the command return a special class, the Result which is
  # typically what the command responds with.
  module Resultable
    # Most of the functionality is at class level since it receives several
    # class instance variables.
    module ClassMethods
      # Returns a result based on the skip_cleanup option
      # skip_cleanup
      #   false    (Default) Returns a result taking returns in account
      #   true     Returns the result skipping the cleanup.
      #   :command Using this option asks to get the command instance rather
      #            than a result. This of course means the command is not clean.
      def result(command, skip_cleanup = false)
        case skip_cleanup
        when :command
          command
        when true
          new_result(command.to_hash)
        else
          new_result(command.to_result_hash)
        end
      end

      # Creates a new instance of a Command::Result with the received values
      # and returns it.
      def new_result(values)
        result_class.new(values)
      end

      # Returns and/or defines the Result class to be returned by the current
      # command.
      # This class is created under the namespace of the command so the end
      # result looks pretty damn cool in my opinion.
      # Eg: Command::Result
      def result_class
        const_defined?('Result') ? const_get('Result') : define_result_class
      end

      private

      # Defines the result class with the necessary modules so it can behave
      # like a result
      def define_result_class
        readers       = self.readers
        command_class = self
        result = Class.new do
          @command_class = command_class
          include Result
          extend  Result::ClassMethods
          attr_reader(*readers)
        end
        const_set 'Result', result
      end
    end

    # This are the methods included to every result class
    module Result
      # These methods are extended to the result class
      module ClassMethods
        attr_reader :command_class
        include Ivar::ClassMethods

        def succeeds
          command_class.succeeds
        end
      end

      include Initializable
      include Inspectable
      include Status::Readable
      include Ivar::Readable
    end
  end
end
