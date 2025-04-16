# frozen_string_literal: true
require_relative "lluminary/version"
require_relative "lluminary/result"
require_relative "lluminary/task"
require_relative "lluminary/providers/base"
require_relative "lluminary/providers/openai"
require_relative "lluminary/config"

module Lluminary
  class << self
    def config
      @config ||= Config.new
    end

    def configure
      yield config
    end

    def reset_configuration
      @config = Config.new
    end
  end
end
