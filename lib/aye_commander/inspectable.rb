module AyeCommander
  # This module handles methods that help a command instance represent its
  # contents in different ways.
  module Inspectable
    # This inspect mimics the one ActiveModel uses so hopefully it will also
    # look pretty during a pry session when the variables become too many.
    def inspect
      inspection = to_hash.map do |name, value|
        "#{name}: #{value}"
      end.compact.join(', ')
      "#<#{self.class} #{inspection}>"
    end

    # Returns a hash of the specified instance_variables
    # Defaults to returning all the currently existing instance variables
    def to_hash(limit = instance_variables)
      limit.each_with_object({}) do |iv, hash|
        ivn = to_ivar(iv)
        hash[ivn] = instance_variable_get(ivn)
      end
    end

    # Returns a hash of only the instance variables that were specified by the
    # .returns method.
    #
    # If no variables were specified then it becomes functionally identical to
    # #to_hash
    def to_result_hash
      if self.class.respond_to?(:returns) && self.class.returns.any?
        to_hash([:status] | self.class.returns)
      else
        to_hash
      end
    end
  end
end
