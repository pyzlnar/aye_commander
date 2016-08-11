module AyeCommander
  # Commander is a special command that lets you run several command in a
  # succession. At the end it returns its own result containing a hash with
  # the commands run.
  module Commander
    # Eventhough the Commander is basically a Command, it does come with some
    # minor tweaking to keep it simple to understand and consistant
    module ClassMethods
      # This ensure that Commander specific class methods are included when
      # Commander is included
      def included(includer)
        super
        includer.extend ClassMethods
        includer.instance_variable_set :@executes, @executes
        includer.instance_variable_set :@abort_on_failure, @abort_on_failure
      end

      # This ensures that the executes instance variable is available for
      # classes that inherit from an included Commander
      def inherited(inheriter)
        super
        inheriter.instance_variable_set :@executes, @executes
        inheriter.instance_variable_set :@abort_on_failure, @abort_on_failure
      end

      # Override of Command.call
      # It's almost identical to a normal command call, the only difference
      # being that it has to prepare the commander result before sending it.
      #
      # This was previously done through hooks, but the idea was scrapped to
      # avoid inconsistencies with the command instance variable during after
      # and aborted hooks
      def call(skip_cleanup: false, **args)
        commander = super(skip_cleanup: :command, **args)
        prepare_commander_result(commander)
        result(commander, skip_cleanup)
      end

      # This method is always run before retuning the result of the commander
      # It basically removes command instance variable since it's only relevant
      # during the execution of the commander itself.
      # It also assigns the ivars of the last executed command to itself.
      def prepare_commander_result(commander)
        commander.instance_exec do
          command.to_hash.each do |name, value|
            instance_variable_set to_ivar(name), value
          end
          remove!(:command)
        end
      end

      # This returns an anonymous command class to be used to initialize the
      # received commander args.
      def command
        @command ||= Class.new.send(:include, Command)
      end

      # Adds the received arguments to the executes array
      def execute(*args)
        executes.concat(args)
      end

      # Returns the executes array
      def executes
        @executes ||= []
      end

      # Can be used to set a default behaviour of a Commander that overwrites
      # call.
      def abort_on_failure(value = true)
        @abort_on_failure = value
      end

      # Returns the abort_on_failure variable
      def abort_on_failure?
        @abort_on_failure
      end
    end

    include Command
    extend ClassMethods

    # A commander works with the following instance variables:
    # command:  The last executed command. Will be an anonymous empty command at
    #           the beginning
    # executed: An array containing the executed commands
    def initialize(**args)
      super(command: self.class.command.new(args), executed: [])
    end

    # This is the default call for a commander
    # It basically just executes the commands saved in the executes array.
    # This however can be overwritten by the user and define their own logic
    # to execute different commands
    def call
      execute(*self.class.executes, abort_on_failure: true)
    end

    private

    # Execute will run the commands received, save the last executed command in
    # @command instance variable and push it to the executed array.
    #
    # It also comes with an option to to abort the Commander in case one of the
    # command run fails.
    def execute(*commands, abort_on_failure: self.class.abort_on_failure?)
      commands.each do |command_class|
        args = command.to_hash
        options = { skip_cleanup: :command, skip_validations: :receives }
        @command = command_class.call(**args, **options)
        executed.push(command)

        if command.failure? && abort_on_failure
          fail!
          abort!
        end
      end
    end
  end
end
