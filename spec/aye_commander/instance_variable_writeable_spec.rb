describe AyeCommander::InstanceVariableWriteable do
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
