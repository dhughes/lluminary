require 'ostruct'
require_relative 'schema'
require 'json'

module Luminary
  class Task
    class << self
      def input_schema(&block)
        @input_schema = Schema.new
        @input_schema.instance_eval(&block)
      end

      def output_schema(&block)
        @output_schema = Schema.new
        @output_schema.instance_eval(&block)
      end

      def use_provider(provider_name, **config)
        provider_class = case provider_name
        when :openai
          require_relative 'providers/openai'
          Providers::OpenAI
        when :test
          require_relative 'providers/test'
          Providers::Test
        else
          raise ArgumentError, "Unknown provider: #{provider_name}"
        end

        @provider = provider_class.new(**config)
      end

      def call(input)
        new(input).call
      end

      def provider
        @provider ||= begin
          require_relative 'providers/test'
          Providers::Test.new
        end
      end

      def provider=(provider)
        @provider = provider
      end

      def input_fields
        @input_schema&.fields || {}
      end

      def output_fields
        @output_schema&.fields || {}
      end
    end

    attr_reader :input, :output, :raw_response, :parsed_response

    def initialize(input)
      @input = OpenStruct.new(input)
      define_input_methods
    end

    def call
      validate_input
      response = self.class.provider.call(prompt, self)
      process_response(response)
      self
    end

    def prompt
      base_prompt = <<~PROMPT
        #{task_prompt}

        You must respond with a valid JSON object in the following format:
        #{json_schema_example}
      PROMPT
    end

    private

    def validate_input
      # TODO: Implement input validation using schema
    end

    def process_response(response)
      @raw_response = response[:raw]
      @parsed_response = response[:parsed]
      @output = OpenStruct.new(@parsed_response)
    end

    def define_input_methods
      self.class.input_fields.each_key do |name|
        define_singleton_method(name) { @input[name] }
      end
    end

    def task_prompt
      raise NotImplementedError, "Subclasses must implement task_prompt"
    end

    def json_schema_example
      fields = self.class.output_fields
      example = fields.each_with_object({}) do |(name, field), hash|
        hash[name] = case field[:type]
        when :string
          "your #{name} here"
        when :integer
          0
        when :boolean
          true
        when :array
          []
        when :object
          {}
        end
      end
      JSON.pretty_generate(example)
    end
  end
end 