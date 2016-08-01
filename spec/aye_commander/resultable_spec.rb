describe AyeCommander::Resultable do
  let(:command)  { Class.new.send(:include, AyeCommander::Command) }
  let(:instance) { command.new }

  context '#command_result' do
  end

  context '#result_class' do
    it 'should do something' do
    end
  end
end
