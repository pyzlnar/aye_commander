module AyeCommander
  # This is the result returned by the command after running it.
  # NOTE Figure out if a result is needed or just return command instance
  #      instead.
  class Result
    def initialize(command, limit = command.instance_variables)
      limit.each do |iv|
        instance_variable_set iv, iv.instance_variable_get
      end
    end

    def inspect
      inspection = instance_variables.map do |name|
        "#{name} #{instance_variable_get name}"
      end.compact.join(', ')
      "#<#{self.class} #{inspection}>"
    end
  end
end