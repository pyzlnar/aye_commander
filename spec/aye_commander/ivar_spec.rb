describe AyeCommander::Ivar::ClassMethods do
  include_context :command

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

  context '.to_ivar' do
    it 'returns itself when the name is already in ivar form' do
      expect(command.to_ivar(:@var)).to eq :@var
    end

    it 'returns the ivar form when name is not in ivar form' do
      expect(command.to_ivar(:var)).to eq :@var
    end

    it 'is able to handle strings' do
      expect(command.to_ivar('@var')).to eq :@var
      expect(command.to_ivar('var')).to  eq :@var
    end
  end

  context '.to_nvar' do
    it 'returns itself when name is already in nvar form' do
      expect(command.to_nvar(:var)).to eq :var
    end

    it 'returns the nvar form when name is not in nvar form' do
      expect(command.to_nvar(:@var)).to eq :var
    end

    it 'is able to handle strings' do
      expect(command.to_nvar('@var')).to eq :var
      expect(command.to_nvar('var')).to  eq :var
    end
  end
end

describe AyeCommander::Ivar::Readable do
  include_context :command

  context '#method_missing' do
    it 'raises if asked a method without an instance variable defined' do
      expect { instance.taco }.to raise_error NoMethodError
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

  context '#remove!' do
    it 'removes an instance variable' do
      instance.remove!(:status)
      expect(instance.instance_variables).to be_empty
    end
  end

  context '#to_ivar' do
    it 'calls the .to_ivar' do
      instance
      expect(command).to receive(:to_ivar).with(:var)
      instance.to_ivar(:var)
    end
  end

  context '#to_nvar' do
    it 'calls the .to_nvar' do
      expect(command).to receive(:to_nvar).with(:var)
      instance.to_nvar(:var)
    end
  end

  context 'p#respond_to_missing?' do
    it 'returns true if the variable name is defined' do
      instance.instance_variable_set :@taco, :badger
      expect(instance.send(:respond_to_missing?, :taco, [false])).to be true
    end

    it 'uses super if the variable name is not defined' do
      expect(instance.send(:respond_to_missing?, :taco, [false])).to be false
    end

    it 'uses super if the variable name is not valid' do
      expect(instance.send(:respond_to_missing?, :taco!, [false])).to be false
    end
  end
end

describe AyeCommander::Ivar::Writeable do
  include_context :command

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

  context 'p#respond_to_missing?' do
    it 'returns true if variable name ends with =' do
      expect(instance.send(:respond_to_missing?, :taco=, [false])).to be true
    end

    it 'uses super otherwise' do
      expect(instance.send(:respond_to_missing?, :taco, [false])).to be false
    end
  end
end
