module AyeCommander
  # This is the result returned by the command after running it.
  # NOTE Figure out if a result is needed or just return command instance
  #      instead.
  module Resultable

    def result(values)
      result_class.new(values)
    end

    def result_class
      const_defined?('Result') ? const_get('Result') : define_result_class
    end

    private

    def define_result_class
      readers = [:status] | returns
      result = Class.new do
        include Inspectable
        include Statusable

        attr_reader(*readers)

        initialize = lambda do |variables|
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
