module AyeCommander
  # This is the meat of AyeComander, what you will include in your commands.
  module Command
    def self.included(includer)
      includer.extend ClassMethods
    end

    # Class Methods to be extended to the includer
    module ClassMethods
      LIMITERS = %i(receives requires returns).freeze

      def call(**args)
        new(args).call
      end

      LIMITERS.each do |limiter|
        body = lambda do |*args|
          attr_accessor(*args)
          prev_limiter = instance_variable_get("@#{limiter}") || []
          instance_variable_set "@#{limiter}", prev_limiter | args
        end
        define_method limiter, body
      end
    end

    def initialize(**args)
      _validate_arguments(args)
      @status = :success
      args.each do |name, value|
        instance_variable_set "@#{name}", value
      end
    end

    def call
    end

    def success?
      status == success
    end

    def method_missing(name, *args)
      instance_variable_get "@#{name}" || super
    end

    def respond_to_missing?(name, *args)
      instance_variable_get "@#{name}" || super
    end

    private

    def _validate_arguments(**args)
      if (requires = self.class.instance_variable_get :@requires)
        _validate_required_arguments(requires, args)
      end

      if (receives = self.class.instance_variable_get :@receives)
        _validate_received_arguments(receives, args)
      end
    end

    def _validate_required_arguments(requires, args)
      missing = requires - args.keys
      raise AyeCommander::MissingRequiredArgument, missing if missing.any?
    end

    def _validate_received_arguments(receives, args)
      extras = args.keys - receives
      raise AyeCommander::UnknownReceivedArgument, extras if extras.any?
    end
  end
end
