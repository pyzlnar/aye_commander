describe AyeCommander::Shareable::ClassMethods do
  include_context :command

  context '.included' do
    it 'ensures that the includer has command methods available' do
      expect(includer.ancestors).to include AyeCommander::Command
      expect(includer.singleton_class.ancestors).to include AyeCommander::Command::ClassMethods
    end

    it 'ensure that even down the line the command methods are available' do
      expect(includer2.ancestors).to include AyeCommander::Command
      expect(includer2.singleton_class.ancestors).to include AyeCommander::Command::ClassMethods
    end

    it 'adds the needed instance variables to the further includers' do
      includer.receives :hopefully_this
      includer.succeeds_with :inclusion
      expect(includer2.receives).to include :hopefully_this
      expect(includer2.succeeds).to include :inclusion
      expect(includer2.send(:hooks)).to be_empty
    end
  end

  context '.inherited' do
    it 'has access to the command class methods' do
      expect(inheriter.ancestors).to include AyeCommander::Command
      expect(inheriter.singleton_class.ancestors).to include AyeCommander::Command::ClassMethods
    end

    it 'adds the needed instance variables to the further inheriters' do
      command.receives :hopefully_this
      command.succeeds_with :inclusion
      expect(inheriter.receives).to include :hopefully_this
      expect(inheriter.succeeds).to include :inclusion
      expect(inheriter.send(:hooks)).to be_empty
    end
  end
end
