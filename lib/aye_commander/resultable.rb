module AyeCommander
  module Resultable
    # This helps define the Result returns after running a command
    module ClassMethods
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

      # Returns an instance of the Result
      def new_result(values)
        result_class.new(values)
      end

      # Returns the Result class of the command
      def result_class
        const_defined?('Result') ? const_get('Result') : define_result_class
      end

      private

      # Defines the Result class
      def define_result_class
        readers = self.readers
        result = Class.new do
          include Initializable
          include Inspectable
          include Status::Readable
          include Ivar::Readable
          extend  Ivar::ClassMethods
          attr_reader(*readers)
        end
        const_set 'Result', result
      end
    end
  end
end
