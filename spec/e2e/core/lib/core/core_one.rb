require 'clean_config'

module Core
  class CoreOne
    include CleanConfig::Configurable

    attr_reader :config

    def initialize
      @config = CleanConfig::Configuration.instance
    end
  end
end
