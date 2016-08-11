describe AyeCommander::Commander::ClassMethods do
  let(:includer)  { Module.new.send(:include, AyeCommander::Commander) }
  let(:includer2) { Module.new.send(:include, includer) }
  let(:inheriter) { Class.new(commander) }

  let(:commander) { Class.new.send(:include,  AyeCommander::Commander) }
  let(:instance)  { commander.new }

  let(:command)   { Class.new.send(:include, AyeCommander::Command) }

  context '.included' do
    it 'includes Commanders Class Methods when included' do
      expect(commander.singleton_class).to include AyeCommander::Commander::ClassMethods
    end

    it 'includes the necessary modules even further down the line' do
      expect(includer2).to include AyeCommander::Commander
      expect(includer2.singleton_class).to include AyeCommander::Commander::ClassMethods
    end

    it 'saves the necessary instance variables for the commander' do
      includer.execute :taco, :burrito
      expect(includer2.executes).to eq %i(taco burrito)
    end
  end

  context '.inherited' do
    it 'includes the necessary modules even further down the line' do
      expect(inheriter).to include AyeCommander::Commander
      expect(inheriter.singleton_class).to include AyeCommander::Commander::ClassMethods
    end

    it 'saves the necessary instance variables for the commander' do
      commander.execute :taco, :burrito
      expect(inheriter.executes).to eq %i(taco burrito)
    end
  end

  context '.call' do
    it 'calls several methods' do
      expect(commander).to receive(:prepare_commander_result)
      expect(commander).to receive(:result).twice
      commander.call
    end
  end

  context '.prepare_commander_result' do
    it 'cleans up the commander after being called' do
      commander.execute(command)
      result = commander.call(taco: :bell)
      expect(result.instance_variables).to include :@status
      expect(result.instance_variables).to include :@executed
      expect(result.instance_variables).to include :@taco
      expect(result.instance_variables).to_not include :@command
    end
  end

  context '.command' do
    it 'gives an anonymous class that includes Command' do
      expect(commander.command).to be_instance_of Class
      expect(commander.command).to include AyeCommander::Command
    end

    it 'always returns the same one per commander' do
      expect(commander.command.object_id).to eq commander.command.object_id
    end
  end

  context '.execute' do
    it 'adds the received arguments to the executes array' do
      commander.execute :taco, :burrito
      expect(commander.executes).to eq %i(taco burrito)
    end
  end

  context '.executes' do
    it 'returns an empty array if it has not been initialized' do
      expect(commander.executes).to be_empty
    end

    it 'returns the content of the class instance variable executes' do
      commander.instance_variable_set :@executes, :random
      expect(commander.executes).to eq :random
    end
  end

  context '.abort_on_failure' do
    it 'sets the @abort_on_failure to true when called without arguments' do
      commander.abort_on_failure
      expect(commander.instance_variable_get :@abort_on_failure).to be true
    end

    it 'sets the @abort_on_failure to the received argument' do
      commander.abort_on_failure false
      expect(commander.instance_variable_get :@abort_on_failure).to be false
    end
  end

  context '.abort_on_failure?' do
    it 'returns @abort_on_failure' do
      expect(commander.abort_on_failure?).to be_nil
      commander.abort_on_failure true
      expect(commander.abort_on_failure?).to be true
    end
  end
end

describe AyeCommander::Commander do
  let(:commander) { Class.new.send(:include, AyeCommander::Commander) }
  let(:instance)  { commander.new }
  let(:command)   { Class.new.send(:include, AyeCommander::Command) }
  let(:commandi)  { command.new }

  context '#initialize' do
    it 'initializes the commander with the required variables' do
      ci = commander.new(taco: :potato)
      expect(ci.command).to be_instance_of commander.command
      expect(ci.executed).to eq []
    end
  end

  context '#call' do
    it 'executes the comamnds in the order they were received' do
      commander.execute(1, 1, 1)
      expect(instance).to receive(:execute).with(1, 1, 1, abort_on_failure: true)
      instance.call
    end
  end

  context '#execute' do
    before do
      commander.class_eval { public :execute }
    end

    it 'calls the command with the result of the previous command' do
      expect(instance.command).to receive(:to_hash).and_return(hello: :world)
      instance.execute(command)
    end

    it 'updates the command variable to the last executed command instance' do
      allow(command).to receive(:call).and_return(commandi)
      instance.execute(command)
      expect(instance.command).to eq commandi
    end

    it 'pushes the command to the executed array' do
      allow(command).to receive(:call).and_return(commandi)
      instance.execute(command)
      expect(instance.executed).to eq [commandi]
    end

    it 'calls fail! and abort! if command fails and with abort_on_failure option' do
      allow(command).to receive(:call).and_return(commandi)
      commandi.fail!

      expect(instance).to receive(:fail!)
      expect(instance).to receive(:abort!)
      instance.execute(command, abort_on_failure: true)
    end

    it 'doesnt calls fail! and abort! even if command fails and without abort_on_failure option' do
      allow(command).to receive(:call).and_return(commandi)
      commandi.fail!

      expect(instance).to_not receive(:fail!)
      expect(instance).to_not receive(:abort!)
      instance.execute(command)
    end

    it 'doesnt calls fail! and abort! if command succeeds even with abort_on_failure option' do
      allow(command).to receive(:call).and_return(commandi)

      expect(instance).to_not receive(:fail!)
      expect(instance).to_not receive(:abort!)
      instance.execute(command, abort_on_failure: true)
    end
  end
end
