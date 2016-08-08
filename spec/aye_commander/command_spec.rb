describe AyeCommander::Command::ClassMethods do
  let(:command)  { Class.new.send(:include, AyeCommander::Command) }
  let(:instance) { command.new }

  context '.call' do
    let(:args) { { some: :other, irrelevant: :args } }

    it 'calls several methods in a specific order' do
      expect(command).to  receive(:new).with(args).and_return(instance)
      expect(command).to  receive(:validate_arguments).with(args)
      expect(command).to  receive(:abortable)
      expect(instance).to receive(:to_result_hash).and_return([])
      expect(command).to  receive(:result).with([])
      command.call(args)
    end

    it 'calls several methods in the abortable block' do
      allow(command).to receive(:new).and_return(instance)
      expect(command).to receive(:call_before_hooks)
      expect(instance).to receive(:call)
      expect(command).to receive(:call_after_hooks)
      command.call(args)
    end

    it 'calls around hooks only if they exist' do
      command.around { :something }
      allow(command).to receive(:new).and_return(instance)
      expect(command).to receive(:call_around_hooks)
      command.call(args)
    end

    it 'calls .to_hash instead of .to_result_hash with :skip_cleanup' do
      allow(command).to receive(:new).and_return(instance)
      expect(instance).to receive(:to_hash).and_return([])
      command.call(**args, skip_cleanup: true)
    end
  end
end

describe AyeCommander::Command do
  let(:command)  { Class.new.send(:include, AyeCommander::Command) }
  let(:instance) { command.new }

  context 'when included' do
    it 'should add the class methods to the includer' do
      expect(command.singleton_class).to include AyeCommander::Command::ClassMethods
    end

    it 'should add the instance methods to the includer' do
      expect(command).to include AyeCommander::Command
    end
  end

  context '#initialize' do
    it 'sets the status to :success if no other succeed has been set' do
      command.succeeds_with :potato
      expect(instance.status).to eq :success
    end

    it 'sets the status to the first suceed if success has been excluded' do
      command.succeeds_with :potato, exclude_success: true
      expect(instance.status).to eq :potato
    end

    it 'sets the instance variables with the received arguments' do
      i = command.new(taco: :burrito, dog: :hungry)
      expect(i.taco).to eq :burrito
      expect(i.dog ).to eq :hungry
    end
  end
end
