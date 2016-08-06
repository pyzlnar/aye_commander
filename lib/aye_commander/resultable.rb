module AyeCommander
  # This helps define the Result returns after running a command
  module Resultable
    # This methods are included at class level to all Commands
    module ClassMethods
      # Returns an instance of the Result
      def result(values)
        result_class.new(values)
      end

      # Returns the Result class of the command
      def result_class
        const_defined?('Result') ? const_get('Result') : define_result_class
      end

      private

      # Defines the Result class
      def define_result_class
        # Define as much as possible whether it's used or not
        readers = [:status] | uses

        result = Class.new do
          include Inspectable
          include Status::Readable
          include IvarReadable
          extend IvarReadable::ClassMethods

          attr_reader(*readers)

          initialize = lambda do |variables = []|
            variables.each do |name, value|
              instance_variable_set name, value
            end
          end

          define_method :initialize, initialize
        end
        const_set 'Result', result
      end
    end
  end
end
