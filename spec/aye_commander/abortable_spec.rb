describe AyeCommander::Abortable::ClassMethods do
  let(:command)  { Class.new.send(:include, AyeCommander::Command) }
  let(:instance) { command.new }

  context '.call_being_abortable' do
    it 'should do nothing if nothing happens' do
      expect(command.call_being_abortable(instance)).to be_nil
    end

    it 'should handle an aborted command correctly' do
      allow(instance).to receive(:call).and_raise(AyeCommander::Aborted)
      expect{ command.call_being_abortable(instance) }.to_not raise_error
      expect(command.call_being_abortable(instance)).to eq :aborted
    end
  end
end

describe AyeCommander::Abortable do
  let(:command)  { Class.new.send(:include, AyeCommander::Command) }
  let(:instance) { command.new }

  context '#abort' do
    it 'should raise a AyeCommander::Aborted exception' do
      expect { instance.abort! }.to raise_error AyeCommander::Aborted
    end
  end
end
