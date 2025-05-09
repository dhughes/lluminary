# frozen_string_literal: true
require "spec_helper"
require "lluminary/providers/test"

RSpec.describe Lluminary::Providers::Test do
  let(:provider) { described_class.new }
  let(:prompt) { "Test prompt" }
  let(:task_class) do
    double("TaskClass", output_fields: { summary: { type: :string } })
  end
  let(:task) { double("Task", class: task_class) }

  describe "#initialize" do
    it "accepts configuration options" do
      config = { api_key: "test_key", model: "test_model" }
      provider = described_class.new(**config)
      expect(provider.config).to eq(config)
    end

    it "merges default provider configuration with instance configuration" do
      # Set up default provider configuration
      Lluminary.configure do |config|
        config.provider(:test, api_key: "global_key", model: "global_model")
      end

      # Create provider with instance-specific config
      provider = described_class.new(model: "instance_model", temperature: 0.7)

      # Should merge default and instance config, with instance taking precedence
      expect(provider.config).to eq(
        api_key: "global_key",
        model: "instance_model",
        temperature: 0.7
      )
    end
  end

  describe "#call" do
    it "returns a hash with raw and parsed response" do
      response = provider.call(prompt, task)

      expect(response).to be_a(Hash)
      expect(response[:raw]).to eq('{"summary": "Test string value"}')
      expect(response[:parsed]).to eq({ "summary" => "Test string value" })
    end

    it "handles prompts with schema descriptions" do
      prompt_with_schema = <<~PROMPT
        Test prompt

        You must respond with a valid JSON object with the following fields:

        summary (string): A brief summary of the message
        Example: "your summary here"

        Your response should look like this:
        {
          "summary": "your summary here"
        }
      PROMPT

      response = provider.call(prompt_with_schema, task)
      expect(response[:raw]).to eq('{"summary": "Test string value"}')
      expect(response[:parsed]).to eq({ "summary" => "Test string value" })
    end

    it "generates integer values for integer fields" do
      task_class =
        double("TaskClass", output_fields: { count: { type: :integer } })
      task = double("Task", class: task_class)

      response = provider.call(prompt, task)
      expect(response[:raw]).to eq('{"count": 0}')
      expect(response[:parsed]).to eq({ "count" => 0 })
    end

    it "raises error for unsupported types" do
      task_class =
        double("TaskClass", output_fields: { value: { type: :unsupported } })
      task = double("Task", class: task_class)

      expect { provider.call(prompt, task) }.to raise_error(
        "Unsupported type: unsupported"
      )
    end
  end
end
