module AyeCommander
  # Core AyeCommander Error
  class Error < RuntimeError
    def initialize(info = nil)
      @info = info
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
  # unspecified arguments
  class UnexpectedReceivedArgumentError < Error
    def message
      "Received unexpected arguments: #{@info}"
    end
  end
end
