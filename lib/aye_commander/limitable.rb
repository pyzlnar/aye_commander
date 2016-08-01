module AyeCommander
  # This module takes care of command arguments being limited by the user
  # specifics.
  module Limitable
    # These methods are the ones that are actually included into the class.
    module ClassMethods
      LIMITERS = %i(receives requires returns).freeze

      # All limiters actually behave the same way at a class level, they just
      # set an instance variable and create attr_accessor for the class.
      # As a side note, this is the reason of why setting a receives is
      # recommended over not specifying any.
      LIMITERS.each do |limiter|
        body = lambda do |*args|
          attr_accessor(*args)
          prev_limiter = instance_variable_get("@#{limiter}") || []
          instance_variable_set "@#{limiter}", prev_limiter | args
        end
        define_method limiter, body
      end
    end

    # These methods are the ones that validate the arguments and do the cleanup
    # duty after running the command. They're contained the Limitable namespace
    # just to not pollute the private namespace of the command.

    def self.validate_arguments(args, requires: [], receives: [])
      validate_required_arguments(requires, args) if requires.any?
      validate_received_arguments(receives, args) if receives.any?
    end

    def self.validate_required_arguments(requires, args)
      missing = requires - args.keys
      raise AyeCommander::MissingRequiredArgument, missing if missing.any?
    end

    def self.validate_received_arguments(receives, args)
      extras = args.keys - receives
      raise AyeCommander::UnknownReceivedArgument, extras if extras.any?
    end
  end
end
