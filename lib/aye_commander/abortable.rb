module AyeCommander
  Aborted = Class.new(RuntimeError)

  # This module helps deal with early exits during a command
  module Abortable
    # This handle the rescue of the Aborted exception.
    module ClassMethods
      def abortable
        yield
        :ok
      rescue Aborted
        :aborted
      end
    end

    # The easiest way to stop the flow from wherever is actually raising an
    # exception. I actually scratched my head for weeks on how Interactor did
    # this before hitting enlightment.
    #
    # In theory using exception for control flow is not recommended since it's
    # slower (and harder to understand) but in these specific scenarios where
    # the code is contained it should be fine. I hope.
    def abort!
      raise Aborted
    end
  end
end
