module AyeCommander
  # This module helps a command to stop the code flow completely and return the
  # result immediately.
  # It is specially useful when your command is running on more deeply nested
  # code (Eg: private methods called by call)
  #
  # It also uses, what is probably one of the most underused features of ruby:
  # catch and throw.
  module Abortable
    # Abortable just comes with a class method that is basically a wrapper for
    # catch and throw.
    module ClassMethods
      # .abortable receives a block and yields it inside a catch so that abort!
      # can be safely called.
      def abortable
        catch(:abort!) { yield }
      end
    end

    # #abort! throws an :abort! to stop the current command flow on its tracks
    def abort!
      throw :abort!, :aborted
    end
  end
end
