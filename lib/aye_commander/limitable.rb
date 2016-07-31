module AyeCommander
  # This module takes care of command arguments being limited by the user
  # specifics.
  module Limitable
    module ClassMethods
      LIMITERS = %i(receives requires returns).freeze

      # All limiters actually behave the same way at a class level, they just
      # set an instance variable and create attr_accessor for the class.
      # As a side note, this is the reason of why setting a receives is
      # recommended over not specifying any.
      LIMITERS.each do |limiter|
        body = lambda do |*args|
          attr_accessor(*args)
          prev_limiter = instance_variable_get("@#{limiter}") || []
          instance_variable_set "@#{limiter}", prev_limiter | args
        end
        define_method limiter, body
      end
    end
  end
end
