describe AyeCommander::Inspectable do
  let(:command)  { Class.new.send(:include, AyeCommander::Command) }
  let(:instance) { command.new }

  context '#inspect' do
    it 'gives a string represntation of the innards of the class' do
      instance.instance_variable_set :@variable, :something
      instance.instance_variable_set :@other, :potato
      expect(instance.inspect).to match /#<#<Class:\dx\w+> @status: success, @variable: something, @other: potato>/
    end
  end
end
