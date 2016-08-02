describe AyeCommander::Resultable do
  let(:command)  { Class.new.send(:include, AyeCommander::Command) }
  let(:instance) { command.new }

  context '#result' do
    let(:result_class) { command.result_class }
    let(:values) { { :@status => :success } }

    it 'returns an instance of the result class' do
      expect(command.result(values)).to be_an_instance_of result_class
    end

    it 'should contain the expected results' do
      expect(command.result(values).to_hash).to eq values
    end
  end

  context '#result_class' do
    it 'returns the result class' do
      expect(command.result_class).to be_an_instance_of Class
      expect(command.result_class).to include AyeCommander::Inspectable
      expect(command.result_class).to include AyeCommander::Statusable
    end

    it 'only defines the class once' do
      expect(command.result_class).to eq command.result_class
    end
  end
end
