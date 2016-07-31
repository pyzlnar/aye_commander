describe AyeCommander::Command do
  let(:command) { Class.new.send(:include, AyeCommander::Command) }
  let(:instance) { command.new }

  context 'when included' do
    it 'should add the class methods to the includer' do
      expect(command.singleton_class.ancestors).to include AyeCommander::Command::ClassMethods
    end
  end

  context '.receives' do
    let(:args){ %i[arg1 arg2] }

    before :each do
      args = %i[arg1 arg2]
      command.receives *args
    end

    it 'should add the received(hurr hurr) values to the :@received variable' do
      expect(command.instance_variable_get(:@receives)).to eq [:arg1, :arg2]
    end

    it 'should create accessors for the received values' do
      args.each do |arg|
        expect(instance).to respond_to arg
        expect(instance).to respond_to "#{arg}="
      end
    end

    it 'should add consecutive receives without any problem' do
      command.receives :arg3
      expect(command.instance_variable_get(:@receives)).to eq [:arg1, :arg2, :arg3]
      expect(instance).to respond_to :arg3
      expect(instance).to respond_to :arg3=
    end

    it 'should not add repeated args' do
      command.receives :arg2
      expect(command.instance_variable_get(:@receives)).to eq [:arg1, :arg2]
    end
  end

  context '.requires' do
    let(:args){ %i[arg1 arg2] }
    let(:instance){ command.new(arg1: 1, arg2: 2, arg3: 3) }

    before :each do
      command.requires *args
    end

    it 'should add the received(hurr hurr) values to the :@received variable' do
      expect(command.instance_variable_get(:@requires)).to eq [:arg1, :arg2]
    end

    it 'should create accessors for the received values' do
      args.each do |arg|
        expect(instance).to respond_to arg
        expect(instance).to respond_to "#{arg}="
      end
    end

    it 'should add consecutive requires without any problem' do
      command.requires :arg3
      expect(command.instance_variable_get(:@requires)).to eq [:arg1, :arg2, :arg3]
      expect(instance).to respond_to :arg3
      expect(instance).to respond_to :arg3=
    end
  end
end
