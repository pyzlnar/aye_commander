describe AyeCommander::Limitable do
  let(:command)   { Class.new.send(:include, AyeCommander::Command) }
  let(:instance)  { command.new }
  let(:limitable) { AyeCommander::Limitable }

  AyeCommander::Limitable::ClassMethods::LIMITERS.each do |limiter|
    context ".#{limiter}" do
      let(:args) { %i(arg1 arg2) }

      before :each do
        allow(AyeCommander::Limitable).to receive(:validate_arguments).and_return(true)
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

  context '.validate_arguments' do
    let(:args) { { hello: :world, how: :are, you: :! } }

    it 'calls .validate_required_arguments if it receives requires' do
      expect(limitable).to receive(:validate_required_arguments).and_return(true)
      limitable.validate_arguments args, requires: [:something]
    end

    it 'does not call .validate_required_arguments if theres no required' do
      expect(limitable).to_not receive(:validate_required_arguments)
      limitable.validate_arguments args
    end

    it 'calls .validate_received_argumnts if it receives receives' do
      expect(limitable).to receive(:validate_received_arguments).and_return(true)
      limitable.validate_arguments args, receives: [:something]
    end

    it 'does not call .validate_received_argumnts if theres no receives' do
      expect(limitable).to_not receive(:validate_received_argumnts)
      limitable.validate_arguments args
    end
  end

  context '.validate_required_arguments' do
    let(:args) { { hello: :world, how: :are, you: :! } }

    it 'does nothing if the required arguments are contained in the received ones' do
      requires = %i(hello you)
      expect { limitable.validate_required_arguments requires, args }.to_not raise_error
    end

    it 'raises an error when the required arguments are not fully contained in the received ones' do
      requires = %i(hello you doc)
      expect { limitable.validate_required_arguments requires, args }.to raise_error AyeCommander::MissingRequiredArgument
    end
  end

  context '.validate_received_arguments' do
    let(:args) { { hello: :world, how: :are, you: :! } }

    it 'does nothing if receives contains all the received arguments' do
      receives = %i(hello how you potato)
      expect { limitable.validate_received_arguments receives, args }.to_not raise_error
    end

    it 'raises an error when it receives arguments not contained in the receives array' do
      receives = %i(hello how potato)
      expect { limitable.validate_received_arguments receives, args }.to raise_error AyeCommander::UnknownReceivedArgument
    end
  end
end
