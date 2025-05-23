# frozen_string_literal: true
require "ostruct"
require "json"
require_relative "schema"
require_relative "validation_error"
# TODO: it seems like there must be a better way to load the models
require_relative "models/base"
require_relative "models/openai/gpt35_turbo"
require_relative "models/bedrock/anthropic_claude_instant_v1"
require_relative "models/google/gemini_20_flash"

module Lluminary
  # Base class for all Lluminary tasks.
  # Provides the core functionality for defining and running LLM-powered tasks.
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
        provider_class =
          case provider_name
          when :anthropic
            require_relative "providers/anthropic"
            Providers::Anthropic
          when :bedrock
            require_relative "providers/bedrock"
            Providers::Bedrock
          when :google
            require_relative "providers/google"
            Providers::Google
          when :openai
            require_relative "providers/openai"
            Providers::OpenAI
          when :test
            require_relative "providers/test"
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
        @provider ||=
          begin
            require_relative "providers/test"
            Providers::Test.new
          end
      end

      attr_writer :provider

      def input_fields
        @input_schema&.fields || {}
      end

      def output_fields
        @output_schema&.fields || {}
      end

      def input_schema_model
        @input_schema&.schema_model || Schema.new.schema_model
      end

      def output_schema_model
        @output_schema&.schema_model || Schema.new.schema_model
      end

      def output_custom_validations
        @output_schema&.custom_validations || []
      end

      def input_custom_validations
        @input_schema&.custom_validations || []
      end
    end

    attr_reader :input, :output, :parsed_response
    attr_accessor :validation_failed

    def initialize(input = {})
      @input = self.class.input_schema_model.new(input)
      @input.task_instance = self
      @validation_failed = false
      define_input_methods
    end

    def call
      if valid?
        response = self.class.provider.call(prompt, self)
        process_response(response)
      else
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
      return if @input.valid?
      raise ValidationError, @input.errors.full_messages.join(", ")
    end

    def prompt
      @prompt ||= self.class.provider.model.format_prompt(self)
    end

    def task_prompt
      raise NotImplementedError, "Subclasses must implement task_prompt"
    end

    # Helper for validation methods to add errors
    def errors
      # Points to the current model being validated - used by custom validation methods
      if @current_model == :output && @output
        @output.errors
      else
        @input.errors
      end
    end

    private

    def define_output_accessor_methods
      return unless @output

      # Define accessor methods for each output field
      @output.attributes.each_key do |name|
        next if name == "raw_response"
        singleton_class.class_eval do
          define_method(name) { @output.attributes[name.to_s] }
        end
      end
    end

    def validate_input
      validate_input!
    end

    def process_response(response)
      @parsed_response = response[:parsed]
      @output = self.class.output_schema_model.new
      @output.task_instance = self
      @output.raw_response = response[:raw]

      # Merge the parsed response first, then validate
      if @parsed_response.is_a?(Hash)
        # Get datetime fields from schema
        datetime_fields =
          self
            .class
            .output_fields
            .select { |_, field| field[:type] == :datetime }
            .keys

        # Convert datetime fields
        converted_response = @parsed_response.dup
        datetime_fields.each do |field_name|
          unless converted_response.key?(field_name.to_s) &&
                   converted_response[field_name.to_s].is_a?(String)
            next
          end
          begin
            converted_response[field_name.to_s] = DateTime.parse(
              converted_response[field_name.to_s]
            )
          rescue ArgumentError
            # Leave as string, validation will fail
          end
        end

        @output.attributes.merge!(converted_response)
      end

      # Define methods to access output attributes directly in validation methods
      define_output_accessor_methods

      # Validate after merging
      @output.valid?

      prompt
    end

    def define_input_methods
      self.class.input_fields.each_key do |name|
        define_singleton_method(name) { @input.attributes[name.to_s] }
      end
    end

    def to_result
      Result.new(
        raw_response: @output&.raw_response,
        output: @parsed_response,
        prompt: prompt
      )
    end
  end
end
