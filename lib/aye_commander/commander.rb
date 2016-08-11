module AyeCommander
  # Commander is a special command that lets you run several command in a
  # succession. At the end it returns its own result containing a hash with
  # the commands run.
  module Commander
    # The only new functionality bundled with the Commander is the class method
    # execute, which can be used to automatically execute a series of commands
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

    # This lambda is run either if the Commander ends successfully or aborts
    # It basically removes the received and command instance variables since
    # they're only relevand during the execution of the commander and assigns
    # the ivars of the last command executed to itself.
    prepare_result = lambda do
      abort! unless command
      command.to_hash.each do |name, value|
        instance_variable_set to_ivar(name), value
      end
      remove!(:received)
      remove!(:command)
    end
    after   prepare_result
    aborted prepare_result

    # A commander works with the following instance variables:
    # received: The original received args by the commander
    # command:  The last executed command. Will be nil at the beginning
    # executed: An array containing the executed commands
    def initialize(**args)
      super(received: args, command: nil, executed: [])
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
      args = command ? command.to_hash : received
      @command = command_class.call(**args, skip_cleanup: :command)
      executed.push(command)

      return unless command.failure? && abort_on_fail
      fail!
      abort!
    end
  end
end
