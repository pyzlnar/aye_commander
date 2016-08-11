describe AyeCommander::Initializable do
  let(:command)  { Class.new.send(:include, AyeCommander::Command) }
  let(:instance) { command.new }

  context '#initialize' do
    it 'sets the instance variables with the received arguments' do
      i = command.new(taco: :burrito, dogo: :hungry)
      expect(i.taco).to eq :burrito
      expect(i.dogo).to eq :hungry
    end

    it 'is able to handle the case when the variable start with @' do
      i = command.new(:@taco => :burrito, :@dogo => :hungry)
      expect(i.taco).to eq :burrito
      expect(i.dogo).to eq :hungry
    end

    it 'is able to handle the case when no args are received' do
      expect{ command.new }.to_not raise_error
    end

    context 'when a command' do
      it 'sets the status to :success if no other succeed has been set' do
        command.succeeds_with :potato
        expect(instance.status).to eq :success
      end

      it 'sets the status to the first suceed if success has been excluded' do
        command.succeeds_with :potato, exclude_success: true
        expect(instance.status).to eq :potato
      end
    end
  end
end
