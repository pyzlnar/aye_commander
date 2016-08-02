module AyeCommander
  # Reuseable module for a more representative inspect
  module Inspectable
    # This inspect mimics the one ActiveModel uses so hopefully it will also
    # look pretty during a pry session when the variables become too many.
    def inspect
      inspection = to_hash.map do |name, value|
        "#{name}: #{value}"
      end.compact.join(', ')
      "#<#{self.class} #{inspection}>"
    end

    # Returns a hash of the specified instance_variables, default all
    def to_hash(limit = instance_variables)
      limit.reduce({}) do |hash, iv|
        ivn = iv =~ /\A@/ ? iv : "@#{iv}".to_sym
        hash[ivn] = instance_variable_get(ivn)
        hash
      end
    end

    # Returns a hash of only the required instance variables
    def to_result_hash
      if self.class.respond_to?(:returns) && self.class.returns.any?
        to_hash([:status] | self.class.returns)
      else
        to_hash
      end
    end
  end
end
