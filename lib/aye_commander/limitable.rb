module AyeCommander
  # This module takes care of command arguments being limited by the user
  # specifics.
  # Be careful since we're abusing module object model a bit and this is
  # actually divided into 2 different scopes. (As a namespace, and using an
  # inner ClassMethod module to extend)
  module Limitable
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

    # These methods are the ones that are included at a class level on every
    # command
    module ClassMethods
      LIMITERS = %i(uses receives requires returns).freeze

      # Contains all the limiters
      def limiters
        @limiters ||= Hash.new([])
      end

      # Helps the command define methods to not use method missing on every
      # instance.
      def uses(*args)
        uses = limiters[:uses]
        return uses if args.empty?

        missing = args - uses
        attr_accessor(*missing) if missing.any?

        limiters[:uses] |= args
      end

      # Defines #receives #requires and #returns
      # #receives Tells the command which arguments are expected to be received
      # #requires Tells the command which arguments are actually required
      # #returns  Tells the command which arguments to return in the result
      LIMITERS[1..-1].each do |limiter|
        define_method(limiter) do |*args|
          return limiters[__method__] if args.empty?
          uses(*args)
          limiters[__method__] |= args
        end
      end
    end
  end
end
