require 'active_support/all'
require 'forwardable'
require 'recursive-open-struct'
require 'singleton'
require 'logger'
require 'yaml'

module CleanConfig
  FileNotFoundException  = Class.new(Exception)
  InvalidConfigException = Class.new(Exception)

  class ConfLogger < Logger
    def initialize(*args)
      super
      self.level = ENV['DEBUG'] ? Logger::DEBUG : Logger::INFO
    end
  end

  # Provides access to data in 'config/config.yml'.
  # Supports both [:property] and '.property' style access to yml configuration
  class Configuration
    include ::Singleton
    extend ::Forwardable

    DEFAULT_CONFIGURATION_DIRECTORY = 'config'
    DEFAULT_CONFIGURATION_FILE_NAME = "#{DEFAULT_CONFIGURATION_DIRECTORY}.yml"
    CODE_DIRECTORIES = %w(lib spec bin)

    LOG = ConfLogger.new(STDOUT)

    def_delegators :@data_hash, :[]

    class << self
      # @param [String] calling_file path of the file that invoked this code
      # @return [String] path to configuration or empty string if not found
      def resolve_config_path(calling_file)
        config_location = File.join(Configuration::DEFAULT_CONFIGURATION_DIRECTORY,
                                    Configuration::DEFAULT_CONFIGURATION_FILE_NAME)

        config_path = find_execution_path(calling_file)
        config_path.empty? ? config_path : File.join(config_path, config_location)
      end

      # Finds a Ruby project's lib directory by looking for a Gemfile sibling
      #
      # @param [String] path The path in which to look for the project's lib directory
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

    # Loads config/config.yml relative to Ruby's execution directory. Useful for accessing config in tests and Rake tasks
    #
    # @return [Configuration] self
    def load!
      add!(File.join(DEFAULT_CONFIGURATION_DIRECTORY, DEFAULT_CONFIGURATION_FILE_NAME))
    end

    # Allows the user to specify a config file other than 'config/config.yml'
    #
    # @param [String] config_path provided as a convenience, but should be avoided in favor of the default location
    # @return [Configuration] self
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
    # @param {Hash} configuration data
    # @return [Configuration] self
    def merge!(config = {})
      @data_hash = @data_hash.nil? ? config : @data_hash.deep_merge(config)
      @data_model = RecursiveOpenStruct.new(@data_hash, recurse_over_arrays: true)
      self
    end

    def parse_key(config_key)
      fail 'config_key required' if config_key.nil? || config_key.empty?
      parse_key_recursive(@data_model, config_key.split('.').reverse, '')
    end

    def method_missing(method, *args, &block)
      @data_model.send(method, *args, &block)
    end

    def empty?
      @data_model.nil?
    end

    def reset!
      @data_model = nil
      @data_hash  = nil
      self
    end

    private

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
