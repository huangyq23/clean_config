require 'logger'
require_relative 'configuration'

module CleanConfig
  module Configurable
    class << self
      def included(_parent)
        log = ConfLogger.new(STDOUT)

        # calling_file is the file name of the Ruby code that is our parent in the call stack.
        calling_file = caller.first.split(':').first
        log.debug("calling_file: #{calling_file}")
        config_path = Configuration.resolve_config_path(calling_file)

        if File.exist?(config_path)
          Configuration.instance.add!(config_path)
          log.debug("Reading configuration from #{config_path}")
          begin
            Configuration.instance.add!(config_path)
          rescue InvalidConfigException
            log.warn("Read configuration from #{config_path}, but configuration not valid. Ignoring, check your config")
          end
        else
          log.debug("Expected config directory #{config_path} not found. Not loading configuration")
        end
      end
    end
  end
end
