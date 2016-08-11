module AyeCommander
  # This is the meat of AyeComander, what the user has to include in his own
  # commands for everything to work.
  module Command
    # Class Methods that define the functionality of a command.
    # The most complex functionality is in fact contained at class level since
    # most I wanted to preserve the commands as clean as possible to avoid
    # name clases or similar.
    module ClassMethods
      include Abortable::ClassMethods
      include Callable::ClassMethods
      include Hookable::ClassMethods
      include Ivar::ClassMethods
      include Limitable::ClassMethods
      include Resultable::ClassMethods
      include Shareable::ClassMethods
      include Status::ClassMethods
    end

    include Abortable
    include Callable
    include Initializable
    include Inspectable
    include Ivar::Readable
    include Ivar::Writeable
    include Status::Readable
    include Status::Writeable
    extend ClassMethods
  end
end
