describe AyeCommander::Ivar::ClassMethods do
  let(:command)  { Class.new.send(:include, AyeCommander::Command) }
  let(:instance) { command.new }
  let(:result)   { command.result_class.new }

  context '.define_missing_reader' do
    it 'calls uses if its a command' do
      expect(command).to receive(:uses).with(:taco)
      command.define_missing_reader(:taco)
    end

    it 'defines the attr_reader if its a result' do
      command.result_class.define_missing_reader(:taco)
      expect(result).to respond_to :taco
      expect(result).to_not respond_to :taco=
    end
  end
end

describe AyeCommander::Ivar::Readable do
  let(:command)  { Class.new.send(:include, AyeCommander::Command) }
  let(:instance) { command.new }

  context '#method_missing' do
    it 'raises if asked a method without an instance variable defined' do
      expect { instance.taco  }.to raise_error NoMethodError
    end

    it 'responds if asked the name of an instance variable' do
      instance.instance_variable_set :@taco, :badger
      expect(instance.taco).to eq :badger
    end

    it 'calls .define_missing_reader' do
      expect(command).to receive(:define_missing_reader).with(:taco)
      instance.instance_variable_set :@taco, :badger
      instance.taco
    end
  end
end

describe AyeCommander::Ivar::Writeable do
  let(:command)  { Class.new.send(:include, AyeCommander::Command) }
  let(:instance) { command.new }

  context '#method_missing' do
    it 'responds to equality assignments' do
      expect { instance.taco = 1 }.to_not raise_error
    end

    it 'defines the method so next time it doesnt go through method_missing' do
      instance.taco = 1
      expect(instance).to respond_to :taco
      expect(instance).to respond_to :taco=
    end
  end
end
