# frozen_string_literal: true

module Lluminary
  # Configuration class for Lluminary framework.
  # Handles global settings and provider configurations.

  class Config
    def initialize
      @providers = {}
    end

    def configure
      yield self
    end

    def provider(name, **options)
      @providers[name.to_sym] = options
    end

    def provider_config(provider_name)
      @providers[provider_name.to_sym] || {}
    end

    def reset!
      @providers = {}
    end
  end
end
