module Luminary
  class Task
    class << self
      def input_schema(&block)
        @input_schema = InputSchema.new
        @input_schema.instance_eval(&block)
      end

      def input_definitions
        @input_schema&.inputs || {}
      end

      def output_schema(&block)
        @output_schema = OutputSchema.new
        @output_schema.instance_eval(&block)
      end

      def output_definitions
        @output_schema&.outputs || {}
      end

      def provider
        @provider ||= Providers::TestProvider.new
      end

      def provider=(provider)
        @provider = provider
      end
    end

    def initialize(inputs = {})
      @inputs = inputs
      define_input_methods
    end

    def self.call(inputs = {})
      new(inputs).call
    end

    def call
      response = self.class.provider.call(prompt: prompt)
      Result.new(
        raw_response: response,
        output: { summary: response }
      )
    end

    def prompt
      raise NotImplementedError, "Subclasses must implement #prompt"
    end

    def input
      @inputs
    end

    private

    def define_input_methods
      self.class.input_definitions.each_key do |name|
        define_singleton_method(name) { @inputs[name] }
      end
    end
  end
end 