module AyeCommander
  # Core AyeCommander Error
  class Error < RuntimeError
    def initialize(info = nil)
      @info = info
    end

    def inspect
      "#<#{self.class}: #{self}>"
    end

    def to_s
      message
    end
  end

  # Raised when command specifies 'requires' and one or more required arguments
  # are missing when called.
  class MissingRequiredArgumentError < Error
    def message
      "Missing required arguments: #{@info}"
    end
  end

  # Raised when the command specifies 'receives' and receives one or more
  # unexpected arguments
  class UnexpectedReceivedArgumentError < Error
    def message
      "Received unexpected arguments: #{@info}"
    end
  end
end
