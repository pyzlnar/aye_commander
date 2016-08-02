describe AyeCommander::Inspectable do
  let(:command)  { Class.new.send(:include, AyeCommander::Command) }
  let(:instance) { command.new }

  before :each do
    instance.instance_variable_set :@variable, :something
    instance.instance_variable_set :@other, :potato
  end

  context '#inspect' do
    it 'gives a string representation of the innards of the class' do
      expect(instance.inspect).to match /#<#<Class:\dx\w+> @status: success, @variable: something, @other: potato>/
    end
  end

  context '#to_hash' do
    it 'gives a hash representation of the innards of the class' do
      result = { :@status => :success, :@variable => :something, :@other => :potato }
      expect(instance.to_hash).to eq result
    end

    it 'gives a hash representation of the innards of the class with the requested values' do
      result = { :@variable => :something, :@other => :potato }
      expect(instance.to_hash([:@variable, :other])).to eq result
    end
  end
end
