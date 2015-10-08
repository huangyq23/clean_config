require 'active_support/all'
require 'forwardable'
require 'recursive-open-struct'
require 'singleton'
require 'logger'
require 'yaml'

module CleanConfig
  # Exception when file not found
  FileNotFoundException  = Class.new(Exception)
  # Exception for configuration parsing errors
  InvalidConfigException = Class.new(Exception)

  # Logger that reads DEBUG environment variable to set level
  class ConfLogger < Logger
    def initialize(*args)
      super
      self.level = ENV['DEBUG'] ? Logger::DEBUG : Logger::INFO
    end
  end

  # Provides access to configuration data
  # Supports both [:property] and '.property' style access to yml configuration
  # Default configuration path is `config/config.yml`
  class Configuration
    include ::Singleton
    extend ::Forwardable

    # directory where configuration yml is expected to be, relative to project root directory
    DEFAULT_CONFIGURATION_DIRECTORY = 'config'

    # name of configuration yml
    DEFAULT_CONFIGURATION_FILE_NAME = "#{DEFAULT_CONFIGURATION_DIRECTORY}.yml"

    # directories commonly found at project root directory, used to find the project root
    CODE_DIRECTORIES = %w(lib spec bin)

    # logger
    LOG = ConfLogger.new(STDOUT)

    def_delegators :@data_hash, :[]

    class << self
      # Finds the full path to the project's configuration file
      #
      # @param [String] calling_file path of the file that invoked this code
      # @return [String] full path to configuration
      def resolve_config_path(calling_file)
        config_location = File.join(Configuration::DEFAULT_CONFIGURATION_DIRECTORY,
                                    Configuration::DEFAULT_CONFIGURATION_FILE_NAME)

        config_path = find_execution_path(calling_file)
        config_path.empty? ? config_path : File.join(config_path, config_location)
      end

      # Finds a Ruby project's lib directory by looking for a Gemfile sibling
      #
      # @param [String] path The path in which to look for the project's lib directory
      # @return [String] the project root directory
      def find_execution_path(path)
        path = File.extname(path).empty? ? path : File.dirname(path)
        directories = path.split(File::Separator)
        project_directory = ''

        until directories.nil? || directories.empty?
          if CODE_DIRECTORIES.include?(directories.last) && project_directory.empty?
            directories.pop
            gemfile_location = File.join(directories.join(File::Separator), 'Gemfile')
            project_directory = File.dirname(gemfile_location) if File.exist?(gemfile_location)
          end
          directories.pop
        end
        project_directory
      end
    end

    # Loads configuration relative to Ruby's execution directory.
    # Useful for accessing config in tests and Rake tasks
    #
    # @return [Configuration] self
    def load!
      add!(File.join(DEFAULT_CONFIGURATION_DIRECTORY, DEFAULT_CONFIGURATION_FILE_NAME))
    end

    # Allows the user to specify a config file other than 'config/config.yml'
    #
    # @param [String] config_path provided as a convenience, but should be avoided in favor of the default location
    # @return [CleanConfig::Configuration] self
    def add!(config_path = nil)
      calling_code_file_path = caller.first.split(':').first
      config_path ||= Configuration.resolve_config_path(calling_code_file_path)
      fail FileNotFoundException, "#{config_path} not found" unless File.exist?(config_path)

      LOG.debug("Reading configuration from #{config_path}")
      config_hash = YAML.load_file(config_path)
      fail InvalidConfigException, "YAML unable to parse empty #{config_path}" unless config_hash # empty YAML returns false

      merge!(config_hash)
    end

    # Set and merge config at runtime without a file
    #
    # @param [Hash] config data to add to configuration
    # @return [CleanConfig::Configuration] self
    def merge!(config = {})
      @data_hash = @data_hash.nil? ? config : @data_hash.deep_merge(config)
      @data_model = RecursiveOpenStruct.new(@data_hash, recurse_over_arrays: true)
      self
    end

    # Given a period-delimited string of keys, find the nested value stored in the configuration
    #
    # @param [String] config_key period-delimited string of nested keys
    # @return [Object] value retrieved
    def parse_key(config_key)
      fail 'config_key required' if config_key.nil? || config_key.empty?
      parse_key_recursive(@data_model, config_key.split('.').reverse, '')
    end

    # Pass along methods not recognized to the underlying data structure
    def method_missing(method, *args, &block)
      @data_model.send(method, *args, &block)
    end

    # Returns whether the configuration is empty or not
    #
    # @return [Boolean] true if configuration is empty
    def empty?
      @data_model.nil?
    end

    # Clear configuration
    #
    # @return [CleanConfig::Configuration] self
    def reset!
      @data_model = nil
      @data_hash  = nil
      self
    end

    private

    # For nested configurations, recursively look for the key
    #
    # @param [Object] data_model configuration object to look for key in
    # @param [String] config_keys period-delimited string of keys to look for
    # @param [String] key_message period-delimited string of keys we are nested in, used for debug output
    # @return [Object] value
    def parse_key_recursive(data_model, config_keys, key_message)
      if config_keys.length > 0
        config_key = config_keys.pop
        key_message << config_key
        configuration = data_model.send(config_key.to_sym)
        fail "config_key #{key_message} has no defined value" unless configuration
        parse_key_recursive(configuration, config_keys, key_message << '.')
      else
        data_model
      end
    end
  end
end
