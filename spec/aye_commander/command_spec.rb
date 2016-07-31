describe AyeCommander::Command do
  let(:command)  { Class.new.send(:include, AyeCommander::Command) }
  let(:instance) { command.new }

  context 'when included' do
    it 'should add the class methods to the includer' do
      expect(command.singleton_class.ancestors).to include AyeCommander::Command::ClassMethods
    end
  end

  AyeCommander::Command::ClassMethods::LIMITERS.each do |limiter|
    context ".#{limiter}" do
      let(:args) { %i(arg1 arg2) }

      before :each do
        allow_any_instance_of(command).to receive(:_validate_arguments).and_return(true)
        command.public_send limiter, *args
      end

      it "should add the #{limiter} values to the :@#{limiter} variable" do
        expect(command.instance_variable_get("@#{limiter}")).to eq [:arg1, :arg2]
      end

      it 'should create accessors for the received values' do
        args.each do |arg|
          expect(instance).to respond_to arg
          expect(instance).to respond_to "#{arg}="
        end
      end

      it "should add consecutive #{limiter} without any problem" do
        command.public_send limiter, :arg3
        expect(command.instance_variable_get("@#{limiter}")).to eq [:arg1, :arg2, :arg3]
        expect(instance).to respond_to :arg3
        expect(instance).to respond_to :arg3=
      end

      it 'should not add repeated args' do
        command.public_send limiter, :arg1, :arg4
        expect(command.instance_variable_get("@#{limiter}")).to eq [:arg1, :arg2, :arg4]
      end
    end
  end
end
