module AyeCommander
  # This module takes care of command arguments being limited by the user
  # specifics.
  module Limitable
    # Limitable is a module which functionality is completely defined at class
    # level.
    module ClassMethods
      LIMITERS = %i(receives requires returns).freeze

      # Contains all the limiters
      def limiters
        @limiters ||= Hash.new([])
      end

      # Helps the command define methods to not use method missing on every
      # instance.
      #
      # The original idea was to encourage to use uses for a small performance
      # boost when running their commands since the methods would be created at
      # load time.
      # This idea has been since scrapped since it would make the commands look
      # very convoluted and the performance hit is probably neglegible since
      # the methods themselves are defined after the first method missing.
      #
      # The functionality however still remains as limited call this method
      # internally
      def uses(*args)
        uses = limiters[:uses]
        return uses if args.empty?

        missing = args - uses
        attr_accessor(*missing) if missing.any?

        limiters[:uses] |= args
      end

      # Defines .receives .requires and .returns
      # .receives Tells the command which arguments are expected to be received
      # .requires Tells the command which arguments are actually required
      # .returns  Tells the command which arguments to return in the result
      LIMITERS.each do |limiter|
        define_method(limiter) do |*args|
          return limiters[__method__] if args.empty?
          uses(*args)
          limiters[__method__] |= args
        end
      end

      # Helper method that tells the result class which methods to create as
      # readers the first time it is created.
      def readers
        [:status] | uses
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
      # Required arguments are ones that your commander absolutely needs to be
      # able to run properly.
      def validate_required_arguments(args)
        missing = requires - args.keys
        raise MissingRequiredArgumentError, missing if missing.any?
      end

      # Validates the received arguments
      # Received arguments are the ones that your command is able to receive.
      # Any other argument not defined by this would be considered an error.
      def validate_received_arguments(args)
        extras = args.keys - (receives | requires)
        raise UnexpectedReceivedArgumentError, extras if extras.any?
      end
    end
  end
end
