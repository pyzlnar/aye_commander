module AyeCommander
  # This module helps Command and Result to be able to respond to various
  # status and status responses.
  module Status
    DEFAULT = :success

    # Status related class Methods to be included
    module ClassMethods
      # Returns and/or initializes the :@succeeds class instance variable
      def succeeds
        @succeeds ||= [DEFAULT]
      end

      # Adds extra succeeds status other than success.
      # Use exclude_success: true if for whathever reason you don't want
      # :success to be a successful status.
      def succeeds_with(*args, exclude_success: false)
        @succeeds = succeeds | args
        @succeeds.delete(DEFAULT) if exclude_success
      end
    end

    # These module defines methods that allow to read and know about the status
    module Readable
      attr_reader :status

      # Whether or not the command is succesful
      def success?
        self.class.succeeds.include?(status)
      end

      # Boolean opposite of success
      def failure?
        !success?
      end
    end

    # These module defines methods that allow to modify the status
    module Writeable
      attr_writer :status

      # Fails the status
      def fail!(status = :failure)
        @status = status
      end
    end
  end
end
