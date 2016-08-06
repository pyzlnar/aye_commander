describe AyeCommander::Limitable do
  let(:command)   { Class.new.send(:include, AyeCommander::Command) }
  let(:instance)  { command.new }
  let(:limitable) { AyeCommander::Limitable }

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

    it 'does nothing if it receives extra arguments' do
      requires = %i(hello you)
      expect { limitable.validate_required_arguments requires, **args, extra: :arg }.to_not raise_error
    end

    it 'raises an error when the required arguments are not fully contained in the received ones' do
      requires = %i(hello you doc)
      expect { limitable.validate_required_arguments requires, args }.to raise_error AyeCommander::MissingRequiredArgumentError
    end
  end

  context '.validate_received_arguments' do
    let(:args) { { hello: :world, how: :are, you: :! } }

    it 'does nothing if receives contains all the received arguments' do
      receives = %i(hello how you)
      expect { limitable.validate_received_arguments receives, args }.to_not raise_error
    end

    it 'does nothing if some of the arguments are missing' do
      receives = %i(hello how you potato)
      expect { limitable.validate_received_arguments receives, args }.to_not raise_error
    end

    it 'raises an error when it receives arguments not contained in the receives array' do
      receives = %i(hello how potato)
      expect { limitable.validate_received_arguments receives, args }.to raise_error AyeCommander::UnknownReceivedArgumentError
    end
  end

  context 'ClassMethods' do
    let(:args) { %i(arg1 arg2) }

    before :each do
      allow(AyeCommander::Limitable).to receive(:validate_arguments).and_return(true)
    end

    context '#uses' do
      it 'should call save_variable' do
        command.uses(*args)
        expect(command.uses).to eq args
      end

      it 'should create accessors for the received values' do
        command.uses(*args)
        args.each do |arg|
          expect(instance).to respond_to arg
          expect(instance).to respond_to "#{arg}="
        end
      end
    end

    %i(receives requires returns).each do |limiter|
      context "##{limiter}" do
        before :each do
          command.public_send limiter, *args
        end

        it 'should call .uses' do
          expect(command).to receive(:uses).with(*args).and_return(true)
          command.public_send limiter, *args
        end

        it 'should save the values to a class instance variable' do
          expect(command.limiters[limiter]).to eq args
        end

        it 'should add consecutive values without any problem' do
          command.public_send limiter, :arg3
          expect(command.limiters[limiter]).to eq %i(arg1 arg2 arg3)
        end

        it 'should not add repeated args' do
          command.public_send limiter, :arg1, :arg4
          expect(command.limiters[limiter]).to eq %i(arg1 arg2 arg4)
        end
      end
    end
  end
end
