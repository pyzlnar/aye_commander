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
      end

      # This ensures that the executes instance variable is available for
      # classes that inherit from an included Commander
      def inherited(inheriter)
        super
        inheriter.instance_variable_set :@executes, @executes
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
      self.class.executes.each do |command_class|
        execute(command_class, abort_on_fail: true)
      end
    end

    private

    # Execute will run the command received, saved said command in the @command
    # instance variable and as well push it to the executed array.
    # It also comes with an option to to abort the Commander in case the command
    # that was run failed.
    def execute(command_class, abort_on_fail: false)
      args = command.to_hash
      @command = command_class.call(**args, skip_cleanup: :command)
      executed.push(command)

      return unless command.failure? && abort_on_fail
      fail!
      abort!
    end
  end
end
