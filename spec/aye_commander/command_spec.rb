describe AyeCommander::Command::ClassMethods do
  let(:command)  { Class.new.send(:include, AyeCommander::Command) }
  let(:instance) { command.new }

  context '.call' do
    let(:args) { { some: :other, irrelevant: :args } }

    it 'calls several methods in a specific order' do
      expect(command).to  receive(:new).with(args).and_return(instance)
      expect(command).to  receive(:validate_arguments).with(args)
      expect(command).to  receive(:abortable)
      expect(command).to  receive(:result).with(instance, false)
      command.call(args)
    end

    it 'runs the aborted hooks if command was aborted' do
      allow(command).to  receive(:call_before_hooks){ throw :abort!, true }
      expect(command).to receive(:call_aborted_hooks)
      command.call(args)
    end

    it 'calls several methods in the abortable block' do
      allow(command).to   receive(:new).and_return(instance)
      expect(command).to  receive(:call_before_hooks)
      expect(instance).to receive(:call)
      expect(command).to  receive(:call_after_hooks)
      expect(command).to_not receive(:call_aborted_hooks)
      command.call(args)
    end

    it 'calls around hooks only if they exist' do
      command.around { :something }
      allow(command).to  receive(:new).and_return(instance)
      expect(command).to receive(:call_around_hooks)
      command.call(args)
    end
  end
end

describe AyeCommander::Command do
  let(:command)  { Class.new.send(:include, AyeCommander::Command) }
  let(:instance) { command.new }

  context '#initialize' do
    it 'sets the status to :success if no other succeed has been set' do
      command.succeeds_with :potato
      expect(instance.status).to eq :success
    end

    it 'sets the status to the first suceed if success has been excluded' do
      command.succeeds_with :potato, exclude_success: true
      expect(instance.status).to eq :potato
    end
  end
end
