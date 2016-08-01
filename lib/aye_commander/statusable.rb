module AyeCommander
  # This module helps Command and Result to be able to respond to various
  # status and status responses.
  module Statusable
    # Status related class Methods to be included
    module ClassMethods
      # Returns and/or initializes the :@succeeds class instance variable
      def succeeds
        @succeeds ||= [:success]
      end

      # Adds extra succeeds status other than success.
      # Use exclude_success: true if for whathever reason you don't want
      # :success to be a successful status.
      def succeeds_with(*args, exclude_success: false)
        @succeeds = succeeds | args
        @succeeds.delete(:success) if exclude_success
      end
    end

    attr_accessor :status

    # Whether or not the command is succesfull
    def success?
      self.class.succeeds.include?(status)
    end

    # Boolean opposite of success
    def failure?
      !success?
    end
  end
end
