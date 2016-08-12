describe AyeCommander::Resultable::ClassMethods do
  include_context :command

  context '.result' do
    it 'returns the command if command option is specified' do
      expect(command.result(instance, :command)).to eq instance
    end

    it 'calls and returns .new_result with the complete hash if true option is specified' do
      expect(instance).to receive(:to_hash).and_return(:stubbed)
      expect(command).to  receive(:new_result).with(:stubbed).and_return(:result)
      expect(command.result(instance, true)).to eq :result
    end

    it 'calls and returns .new_result with the result hash if no option is specified' do
      expect(instance).to receive(:to_result_hash).and_return(:stubbed)
      expect(command).to  receive(:new_result).with(:stubbed).and_return(:result)
      expect(command.result(instance, false)).to eq :result
    end
  end

  context '.new_result' do
    let(:values) { { :@status => :success } }

    it 'returns an instance of the result class' do
      expect(command.new_result(values)).to be_an_instance_of result_class
    end

    it 'should contain the expected results' do
      expect(command.new_result(values).to_hash).to eq values
    end
  end

  context '.result_class' do
    it 'returns the result class' do
      expect(result_class).to be_an_instance_of Class
    end

    it 'defines the class under the Result const name' do
      expect(result_class).to eq command.const_get('Result')
    end

    it 'only defines the class once' do
      expect(result_class.object_id).to eq command.result_class.object_id
    end

    it 'includes the necessary result modules' do
      expect(result_class).to include AyeCommander::Initializable
      expect(result_class).to include AyeCommander::Inspectable
      expect(result_class).to include AyeCommander::Status::Readable
      expect(result_class).to include AyeCommander::Ivar::Readable
    end

    it 'extends the necessary result modules' do
      expect(result_class.singleton_class).to include AyeCommander::Ivar::ClassMethods
    end

    it 'defines readers for the class' do
      command.uses :variable
      expect(result_class.new).to respond_to :variable
      expect(result_class.new).to_not respond_to :variable=
    end
  end
end
