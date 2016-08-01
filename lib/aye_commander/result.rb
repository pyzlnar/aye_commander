module AyeCommander
  # This is the result returned by the command after running it.
  # NOTE Figure out if a result is needed or just return command instance
  #      instead.
  class Result
    include Inspectable
    include Statusable

    def initialize(command, limit = [])
      limit = command.instance_variables if limit.empty?
      limit.each do |iv|
        instance_variable_set iv, command.instance_variable_get(iv)
      end
    end
  end
end
