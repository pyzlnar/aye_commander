module AyeCommander
  # This is the result returned by the command after running it.
  # NOTE Figure out if a result is needed or just return command instance
  #      instead.
  module Resultable
    def command_result(command)
      result_class.new(command, [:status] | returns)
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

        initialize = lambda do |command, limit = []|
          limit = command.instance_variables if limit.one?
          limit.each do |iv|
            ivn = iv =~ /\A@/ ? iv : "@#{iv}"
            instance_variable_set ivn, command.instance_variable_get(ivn)
          end
        end

        define_method :initialize, initialize
      end
      const_set 'Result', result
    end
  end
end
