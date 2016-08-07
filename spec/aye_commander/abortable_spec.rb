describe AyeCommander::Abortable::ClassMethods do
  let(:command)  { Class.new.send(:include, AyeCommander::Command) }
  let(:instance) { command.new }

  context '.abortable' do
    it 'should return :ok if nothing happens' do
      expect(command.abortable { :nothing } ).to eq :ok
    end

    it 'should not raise an error if nothing happens' do
      expect { command.abortable { :nothing } }.to_not raise_error
    end

    it 'should return :aborted if abort happens' do
      expect(command.abortable { raise AyeCommander::Aborted } ).to eq :aborted
    end

    it 'should not raise if abort happens' do
      expect { command.abortable { raise AyeCommander::Aborted } }.to_not raise_error
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
