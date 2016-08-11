module AyeCommander
  # This module helps deal with early exits during a command
  module Abortable
    # Abortable class methods
    module ClassMethods
      # Catches :abort! to make sure everything is ok
      def abortable
        catch(:abort!) { yield }
      end
    end

    # Throws an :abort! to stop the current command flow
    def abort!
      throw :abort!, :aborted
    end
  end
end
