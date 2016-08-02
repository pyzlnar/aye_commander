describe AyeCommander::InstanceVariableReadable do
  let(:command)  { Class.new.send(:include, AyeCommander::Command) }
  let(:instance) { command.new }
  let(:result)   { command.result_class.new }

  context '#method_missing' do
    it 'raises if asked a method without an instance variable defined' do
      expect { instance.taco  }.to raise_error NoMethodError
    end

    it 'responds if asked the name of an instance variable' do
      instance.instance_variable_set :@taco, :badger
      expect(instance.taco).to eq :badger
    end

    it 'defines the method so next time it doesnt go through method_missing' do
      instance.instance_variable_set :@taco, :badger
      instance.taco
      expect(instance).to respond_to :taco
      expect(instance).to respond_to :taco=
    end

    it 'when in a result it defines the reader to avoid method_missing the next time' do
      result.instance_variable_set :@taco, :badger
      result.taco
      expect(result).to respond_to :taco
      expect(result).to_not respond_to :taco=
    end
  end
end
