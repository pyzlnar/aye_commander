module AyeCommander
  module Shareable
    # This module serves to make sure that when included or inherited everything
    # related to the command is preserved
    # Prepend is not really supported, but you really shouldnt be prepending a
    # Command so... meh
    module ClassMethods
      # This ensures that class methods are extended when Command is included
      def included(includer)
        super
        includer.extend AyeCommander::Command::ClassMethods
        %i(@limiters @succeeds @hooks).each do |var|
          if instance_variable_defined? var
            includer.instance_variable_set var, instance_variable_get(var)
          end
        end
      end

      # Rubys object model already links the ancestry path of singleton classes
      # when using classic inheritance so no need to extend. Just need to add
      # the variables to the inheriter.
      def inherited(inheriter)
        super
        %i(@limiters @succeeds @hooks).each do |var|
          if instance_variable_defined? var
            inheriter.instance_variable_set var, instance_variable_get(var)
          end
        end
      end
    end
  end
end
