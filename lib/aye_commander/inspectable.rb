module AyeCommander
  # Reuseable module for a more representative inspect
  module Inspectable
    # This inspect mimics the one ActiveModel uses so hopefully it will also
    # look pretty during a pry session when the variables become too many.
    def inspect
      inspection = instance_variables.map do |name|
        "#{name}: #{instance_variable_get name}"
      end.compact.join(', ')
      "#<#{self.class} #{inspection}>"
    end
  end
end
