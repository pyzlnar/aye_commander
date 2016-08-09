describe AyeCommander::Resultable::ClassMethods do
  let(:command)  { Class.new.send(:include, AyeCommander::Command) }
  let(:instance) { command.new }
  let(:result_class) { command.result_class }

  context '.result' do
    let(:values) { { :@status => :success } }

    it 'returns an instance of the result class' do
      expect(command.result(values)).to be_an_instance_of result_class
    end

    it 'should contain the expected results' do
      expect(command.result(values).to_hash).to eq values
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
  end

  context 'p.define_result_class' do
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
