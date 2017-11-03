describe AyeCommander::Inspectable do
  include_context :command

  before :each do
    instance.instance_variable_set :@variable, :something
    instance.instance_variable_set :@other, :potato
  end

  context '#inspect' do
    it 'gives a string representation of the innards of the class' do
      expect(instance.inspect).to match(/#<#<Class:\dx\w+> @status: success, @variable: something, @other: potato>/)
    end
  end

  context '#pretty_print' do
    it 'gives a pretty print representation of the innards of the class' do
      pretty_print = PP.pp(instance, ''.dup)
      expect(pretty_print).to match(/#<#<Class:\dx\w+>:\dx\w+\n @status: :success,\n @other: :potato,\n @variable: :something>/)
    end
  end

  context '#to_hash' do
    it 'gives a hash representation of the innards of the class' do
      result = { :@status => :success, :@variable => :something, :@other => :potato }
      expect(instance.to_hash).to eq result
    end

    it 'gives a hash representation of the innards of the class with the requested values' do
      result = { :@variable => :something, :@other => :potato }
      expect(instance.to_hash(%i[@variable other])).to eq result
    end
  end

  context '#to_result_hash' do
    it 'gives a hash of all values for the result if no return was specified' do
      result = { :@status => :success, :@variable => :something, :@other => :potato }
      expect(instance.to_result_hash).to eq result
    end

    it 'gives the necessary values for the result when a return was specified' do
      command.returns :other
      result = { :@status => :success, :@other => :potato }
      expect(instance.to_result_hash).to eq result
    end

    it 'assigns nil to the values that were not created when a result was specified' do
      command.returns :badger
      result = { :@status => :success, :@badger => nil }
      expect(instance.to_result_hash).to eq result
    end
  end

  context '#sorted_instance_variables' do
    it 'sorts the instance variables alphabetically but keeps @status at the beginning' do
      sorted = %i[@status @other @variable]
      expect(instance.sorted_instance_variables).to eq sorted
    end
  end
end
