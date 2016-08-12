describe AyeCommander::Abortable::ClassMethods do
  include_context :command

  context '.abortable' do
    it 'does nothing if nothing happens' do
      expect { command.abortable { :nothing } }.to_not raise_error
    end

    it 'is able to catch throw(:abort!)' do
      expect { command.abortable { throw :abort! } }.to_not raise_error
    end
  end
end

describe AyeCommander::Abortable do
  include_context :command

  context '#abort' do
    it 'throws with :abort! symbol' do
      expect(instance).to receive(:throw).with(:abort!, :aborted)
      instance.abort!
    end
  end
end
