describe AyeCommander::Initializable do
  let(:command)  { Class.new.send(:include, AyeCommander::Command) }

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
  end
end
