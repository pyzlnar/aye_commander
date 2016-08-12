describe AyeCommander::Command do
  include_context :command

  context 'a command' do
    it 'includes the necessary instance modules' do
      expect(command).to include AyeCommander::Abortable
      expect(command).to include AyeCommander::Callable
      expect(command).to include AyeCommander::Initializable
      expect(command).to include AyeCommander::Inspectable
      expect(command).to include AyeCommander::Ivar::Readable
      expect(command).to include AyeCommander::Ivar::Writeable
      expect(command).to include AyeCommander::Status::Readable
      expect(command).to include AyeCommander::Status::Writeable
    end

    it 'includes the necessary class modules' do
      expect(commandsc).to include AyeCommander::Abortable::ClassMethods
      expect(commandsc).to include AyeCommander::Callable::ClassMethods
      expect(commandsc).to include AyeCommander::Hookable::ClassMethods
      expect(commandsc).to include AyeCommander::Ivar::ClassMethods
      expect(commandsc).to include AyeCommander::Limitable::ClassMethods
      expect(commandsc).to include AyeCommander::Resultable::ClassMethods
      expect(commandsc).to include AyeCommander::Shareable::ClassMethods
      expect(commandsc).to include AyeCommander::Status::ClassMethods
    end
  end
end
