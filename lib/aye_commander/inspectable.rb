module AyeCommander
  # This module handles methods that help a command instance represent its
  # contents in different ways.
  module Inspectable
    # This inspect mimics ActiveModel for a better inspection.
    def inspect
      inspection = to_hash.map do |name, value|
        "#{name}: #{value}"
      end.compact.join(', ')
      "#<#{self.class} #{inspection}>"
    end

    # This method mimics ActiveModel pretty_print for a better console output.
    def pretty_print(pp)
      pp.object_address_group(self) do
        ivs = sorted_instance_variables.map(&:to_s)
        pp.seplist(ivs, proc { pp.text ',' }) do |iv|
          pp.breakable ' '
          pp.group(1) do
            pp.text iv
            pp.text ':'
            pp.breakable
            pp.pp instance_variable_get(iv)
          end
        end
      end
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

    # Sorts the instance variables in alphabetical order, but keeps @status at
    # the beginning for easier inspection
    def sorted_instance_variables
      [:@status] | instance_variables.sort
    end
  end
end
