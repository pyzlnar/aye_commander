describe AyeCommander::Command do
  let(:command)  { Class.new.send(:include, AyeCommander::Command) }
  let(:instance) { command.new }

  context 'when included' do
    it 'should add the class methods to the includer' do
      expect(command.singleton_class.ancestors).to include AyeCommander::Command::ClassMethods
    end
  end

  context '#initialize' do
    it 'sets the status to :success if no other succeed has been set' do
      command.succeeds_with :potato
      expect(instance.status).to eq :success
    end

    it 'sets the status to the first suceed if success has been excluded' do
      command.succeeds_with :potato, exclude_success: true
      expect(command.new.status).to eq :potato
    end
  end
end
