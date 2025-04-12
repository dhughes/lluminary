require 'ostruct'
require_relative 'schema'
require_relative 'validation_error'
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

      def call(input = {})
        new(input).call
      end

      def call!(input = {})
        new(input).call!
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

      def input_schema_model
        @input_schema&.schema_model || Schema.new.schema_model
      end
    end

    attr_reader :input, :output, :raw_response, :parsed_response

    def initialize(input = {})
      @input = self.class.input_schema_model.new(input)
      define_input_methods
    end

    def call
      if valid?
        response = self.class.provider.call(prompt, self)
        process_response(response)
      else
        @raw_response = nil
        @parsed_response = nil
        @output = nil
      end

      self
    end

    def call!
      validate_input!
      response = self.class.provider.call(prompt, self)
      process_response(response)
      
      self
    end

    def valid?
      @input.valid?
    end

    def validate_input!
      unless @input.valid?
        raise ValidationError, @input.errors.full_messages.join(", ")
      end
    end

    def prompt
      base_prompt = <<~PROMPT
        #{task_prompt}

        #{json_schema_example}
      PROMPT
    end

    private

    def validate_input
      validate_input!
    end

    def process_response(response)
      @raw_response = response[:raw]
      @parsed_response = response[:parsed]
      @output = OpenStruct.new(@parsed_response)
      @prompt = prompt
    end

    def define_input_methods
      self.class.input_fields.each_key do |name|
        define_singleton_method(name) { @input.attributes[name.to_s] }
      end
    end

    def task_prompt
      raise NotImplementedError, "Subclasses must implement task_prompt"
    end

    def json_schema_example
      fields = self.class.output_fields
      return "{}" if fields.empty?

      # Generate field descriptions
      field_descriptions = fields.map do |name, field|
        type = field[:type]
        description = field[:description]
        example = case type
                 when :string
                   "\"your #{name} here\""
                 when :integer
                   "0"
                 end

        description_line = description ? ": #{description}" : ""
        "#{name} (#{type})#{description_line}\nExample: #{example}"
      end.join("\n\n")

      # Generate example JSON
      example_json = fields.each_with_object({}) do |(name, field), hash|
        hash[name] = case field[:type]
                    when :string
                      "your #{name} here"
                    when :integer
                      0
                    end
      end

      <<~SCHEMA.chomp
        You must respond with a valid JSON object with the following fields:

        #{field_descriptions}

        Your response should look like this:
        #{JSON.pretty_generate(example_json)}
      SCHEMA
    end

    def to_result
      Result.new(
        raw_response: @raw_response,
        output: @parsed_response,
        prompt: @prompt
      )
    end
  end
end 