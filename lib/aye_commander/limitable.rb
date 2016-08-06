module AyeCommander
  # This module takes care of command arguments being limited by the user
  # specifics.
  module Limitable
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

      # Validates the limiter arguments
      def validate_arguments(args, skip_validations: false)
        unless [true, :requires].include?(skip_validations) || requires.empty?
          validate_required_arguments(args)
        end

        unless [true, :receives].include?(skip_validations) || receives.empty?
          validate_received_arguments(args)
        end
      end

      # Validates the required arguments
      def validate_required_arguments(args)
        missing = requires - args.keys
        raise AyeCommander::MissingRequiredArgumentError, missing if missing.any?
      end

      # Validates the received arguments
      def validate_received_arguments(args)
        extras = args.keys - (receives | requires)
        raise AyeCommander::UnknownReceivedArgumentError, extras if extras.any?
      end
    end
  end
end
