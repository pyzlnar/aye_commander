describe AyeCommander::Statusable do
  let(:command)  { Class.new.send(:include, AyeCommander::Command) }
  let(:instance) { command.new }

  context 'when included' do
    it 'adds status and status= methods' do
      expect(instance).to respond_to :status
      expect(instance).to respond_to :status=
    end
  end

  context '.succeeds' do
    it 'returns [:success] if nothing else has been set' do
      expect(command.succeeds).to eq [:success]
    end

    it 'returns whathever the :@succeds class instance variable contains' do
      command.instance_variable_set :@succeeds, %i(im a little teapot)
      expect(command.succeeds).to eq %i(im a little teapot)
    end
  end

  context '.suceeds_with' do
    let(:args) { %i(succ1 succ2) }

    before :each do
      command.succeeds_with(*args)
    end

    it 'adds the values to the succeeds array' do
      expect(command.succeeds).to eq %i(success succ1 succ2)
    end

    it 'allows consecutive succeeds' do
      command.succeeds_with :potato
      expect(command.succeeds).to eq %i(success succ1 succ2 potato)
    end

    it 'doesnt add repeated succeeds' do
      command.succeeds_with(*args)
      expect(command.succeeds).to eq %i(success succ1 succ2)
    end

    it 'removes :success from the array if called with the exclude_suceed option' do
      command.succeeds_with exclude_success: true
      expect(command.succeeds).to eq args
    end
  end

  context '#success?' do
    it 'returns true if nothing else is set' do
      expect(instance.success?).to be true
    end

    it 'returns true if status is contained in the succeeds array' do
      command.succeeds_with :taco
      instance.status = :taco
      expect(instance.success?).to be true
    end

    it 'returns false if status is NOT contained in the succeeds array' do
      command.succeeds_with :taco, exclude_success: true
      instance.status = :success
      expect(instance.success?).to be false
    end
  end

  context '#failure?' do
    it 'is the boolean opposite of success' do
      expect(instance.failure?).to be false
    end
  end
end
