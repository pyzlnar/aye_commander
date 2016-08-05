describe AyeCommander::Limitable do
  let(:command)   { Class.new.send(:include, AyeCommander::Command) }
  let(:instance)  { command.new }
  let(:limitable) { AyeCommander::Limitable }

  context 'ClassMethods' do
    let(:args) { %i(arg1 arg2) }

    before :each do
      allow(AyeCommander::Limitable).to receive(:validate_arguments).and_return(true)
    end

    context '.save_variable' do
      before :each do
        command.send :save_variable, :@random, args
      end

      it 'should add the values to the :@random variable' do
        expect(command.instance_variable_get :@random).to eq args
      end

      it 'should add consecutive uses without any problem' do
        command.send :save_variable, :@random, [:arg3]
        expect(command.instance_variable_get :@random).to eq %i(arg1 arg2 arg3)
      end

      it 'should not add repeated args' do
        command.send :save_variable, :@random, [:arg1, :arg4]
        expect(command.instance_variable_get :@random).to eq %i(arg1 arg2 arg4)
      end
    end

    context '.uses' do
      it 'should call save_variable' do
        expect(command).to receive(:save_variable).with(:@uses, args)
        command.uses(*args)
      end

      it 'should create accessors for the received values' do
        command.uses(*args)
        args.each do |arg|
          expect(instance).to respond_to arg
          expect(instance).to respond_to "#{arg}="
        end
      end
    end

    context '.receives' do
      it 'should call .uses' do
        expect(command).to receive(:uses).with(*args).and_return(true)
        command.receives(*args)
      end

      it 'should add the receives values to the :@receives variable' do
        allow(command).to receive(:uses).and_return(true)
        command.receives(*args)
        expect(command.receives).to eq args
      end
    end

    context '.requires' do
      it 'should call .receives' do
        expect(command).to receive(:receives).with(*args).and_return(true)
        command.requires(*args)
      end

      it 'should add the requires values to the :@requires variable' do
        allow(command).to receive(:receives).and_return(true)
        command.requires(*args)
        expect(command.requires).to eq args
      end
    end

    context '.returns' do
      it 'should call .uses' do
        expect(command).to receive(:uses).with(*args).and_return(true)
        command.returns(*args)
      end

      it 'should add the returns values to the :@returns variable' do
        allow(command).to receive(:uses).and_return(true)
        command.returns(*args)
        expect(command.returns).to eq args
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
      expect { limitable.validate_required_arguments requires, args }.to raise_error AyeCommander::MissingRequiredArgumentError
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
      expect { limitable.validate_received_arguments receives, args }.to raise_error AyeCommander::UnknownReceivedArgumentError
    end
  end
end
