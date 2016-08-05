module AyeCommander
  # This module takes care of command arguments being limited by the user
  # specifics.
  module Limitable
    # These methods are the ones that are actually included into the class.
    module ClassMethods
      LIMITERS = %i(uses receives requires returns).freeze

      # Helps the command define methods to not use method missing on every
      # instance.
      def uses(*args)
        @uses ||= []
        missing = args - @uses
        attr_accessor(*missing) if missing.any?
        save_variable(:@uses, args)
      end

      # Tells the command which arguments are expected to be received
      def receives(*args)
        uses(*args)
        save_variable(:@receives, args)
      end

      # Tells the command which arguments are actually required
      def requires(*args)
        receives(*args)
        save_variable(:@requires, args)
      end

      # Tells the command which arguments to return in the result
      def returns(*args)
        uses(*args)
        save_variable(:@returns, args)
      end

      private

      def save_variable(name, args)
        prev = instance_variable_get(name) || []
        instance_variable_set name, prev | args
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
      raise AyeCommander::MissingRequiredArgumentError, missing if missing.any?
    end

    def self.validate_received_arguments(receives, args)
      extras = args.keys - receives
      raise AyeCommander::UnknownReceivedArgumentError, extras if extras.any?
    end
  end
end
