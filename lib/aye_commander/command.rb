module AyeCommander::Command
  def self.call(**args)
    new(args).call
  end

  def self.recieves(*args)
    @recieves ||= []
    @recieves += args
  end

  def self.requires(*args)
    @requires ||= []
    @requires += args
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
    variable = "@#{name}".to_sym
    if instance_variables.include? variable
      instance_variable_get variable
    else
      super
    end
  end

  private
  def _validate_arguments(**args)
    if (required = self.class.instance_variable_get :@requires)
      _validate_required_arguments(requires, args)
    end

    if (recieves = self.class.instance_variable_get :@recieves)
      _validate_recieved_arguments(recieves, args)
    end
  end

  def _validate_required_arguments(requires, args)
    missing = requires - args.keys
    raise MissingRequiredArgument, "Missing required arguments: #{missing}" if missing.any?
  end

  def _validate_recieved_arguments(recieves, args)
    extras = args.keys - recieves
    raise UnknownReceivedArgument, "Recieved unknown arguments: #{extras}" if extras.any?
  end
end
