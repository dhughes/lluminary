module Lluminary
  class Config
    def initialize
      @providers = {}
    end

    def configure
      yield configurator
    end

    def provider_config(provider_name)
      @providers[provider_name.to_sym] || {}
    end

    def reset!
      @providers = {}
    end

    private

    def configurator
      @configurator ||= Configurator.new(self)
    end

    class Configurator
      def initialize(config)
        @config = config
      end

      def provider(name, **options)
        @config.instance_variable_get(:@providers)[name.to_sym] = options
      end
    end
  end
end 