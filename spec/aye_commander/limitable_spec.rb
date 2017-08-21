describe AyeCommander::Limitable::ClassMethods do
  include_context :command
  let(:args) { %i[arg1 arg2] }

  context '.uses' do
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

  %i[receives requires returns].each do |limiter|
    context ".#{limiter}" do
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
        expect(command.limiters[limiter]).to eq %i[arg1 arg2 arg3]
      end

      it 'should not add repeated args' do
        command.public_send limiter, :arg1, :arg4
        expect(command.limiters[limiter]).to eq %i[arg1 arg2 arg4]
      end
    end
  end

  context '.validate_arguments' do
    let(:args) { { hello: :world, how: :are, you: :! } }

    it 'calls .validate_required_arguments if it has requires' do
      expect(command).to receive(:validate_required_arguments).and_return(true)
      command.requires :something
      command.validate_arguments args
    end

    it 'does not call .validate_required_arguments if theres no requires' do
      expect(command).to_not receive(:validate_required_arguments)
      command.validate_arguments args
    end

    it 'does not call .validate_required_arguments with skip_validations: :requires option' do
      command.requires :something
      expect(command).to_not receive(:validate_required_arguments)
      command.validate_arguments args, skip_validations: :requires
    end

    it 'calls .validate_received_arguments if it has receives' do
      expect(command).to receive(:validate_received_arguments).and_return(true)
      command.receives :something
      command.validate_arguments args
    end

    it 'does not call .validate_received_argumnts if theres no receives' do
      expect(command).to_not receive(:validate_received_arguments)
      command.validate_arguments args
    end

    it 'does not call .validate_receiveed_arguments with skip_validations: :receives option' do
      command.receives :something
      expect(command).to_not receive(:validate_received_arguments)
      command.validate_arguments args, skip_validations: :receives
    end

    it 'does not call either with skip_validations: true option' do
      command.requires :something
      command.receives :something_else
      expect(command).to_not receive(:validate_received_arguments)
      expect(command).to_not receive(:validate_required_arguments)

      command.validate_arguments args, skip_validations: true
    end
  end

  context '.validate_required_arguments' do
    let(:args) { { hello: :world, how: :are, you: :! } }

    it 'does nothing if the required arguments are contained in the received ones' do
      command.requires :hello, :you
      expect { command.validate_required_arguments args }.to_not raise_error
    end

    it 'does nothing if it receives extra arguments' do
      command.requires :hello, :you
      expect { command.validate_required_arguments(**args, extra: :arg) }.to_not raise_error
    end

    it 'raises an error when the required arguments are not fully contained in the received ones' do
      command.requires :hello, :you, :doc
      expect { command.validate_required_arguments args }.to raise_error AyeCommander::MissingRequiredArgumentError
    end
  end

  context '.validate_received_arguments' do
    let(:args) { { hello: :world, how: :are, you: :! } }

    it 'does nothing if receives contains all the received arguments' do
      command.receives :hello, :how, :you
      expect { command.validate_received_arguments args }.to_not raise_error
    end

    it 'does nothing if some of the arguments are missing' do
      command.receives :hello, :how, :you, :potato
      expect { command.validate_received_arguments args }.to_not raise_error
    end

    it 'raises an error when it receives arguments not contained in the receives array' do
      command.receives :hello, :how, :potato
      expect { command.validate_received_arguments args }.to raise_error AyeCommander::UnexpectedReceivedArgumentError
    end
  end
end
