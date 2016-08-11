module AyeCommander
  # This is the meat of AyeComander, what you will include in your commands.
  module Command
    include Abortable
    include Callable
    include Initializable
    include Inspectable
    include Ivar::Readable
    include Ivar::Writeable
    include Status::Readable
    include Status::Writeable

    # Class Methods to be extended to the includer
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
    extend ClassMethods
  end
end
