module AyeCommander
  # This module takes care of both .call and #call, the most important methods
  # in a command
  module Callable
    # Class Methods defined by callable
    module ClassMethods
      # .call is what the user calls when he wants to run his commands. It is
      # able to receive several named arguments, and a couple of options for
      # specific behavior on how the command must be run.
      #
      # Options
      # skip_validations: (Handled by validate_arguments)
      #   true      Skips both :receives and :requires argument validations
      #   :requires Skips :requires argument validation
      #   :receives Skips :receives argument validation
      #
      # skip_cleanup:
      #   true     Skips the result cleanup so it has all the instance variables
      #            that were declared
      #   :command Returns the command instead of an instance of the result
      #            class
      def call(skip_cleanup: false, **args)
        command = new(args)
        validate_arguments(args)
        aborted = abortable do
          call_before_hooks(command)
          around_hooks.any? ? call_around_hooks(command) : command.call
          call_after_hooks(command)
        end
        abortable { call_aborted_hooks(command) } if aborted == :aborted
        result(command, skip_cleanup)
      end
    end

    # #call is what a user redefines in their own command, and what he
    # customizes to give a command the behavior he desires.
    # An empty call is defined in a command so they can be run even without one.
    def call
    end
  end
end
