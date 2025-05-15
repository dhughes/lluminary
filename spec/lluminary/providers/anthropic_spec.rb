# frozen_string_literal: true
require "spec_helper"
require "lluminary/providers/anthropic"

RSpec.describe Lluminary::Providers::Anthropic do
  let(:config) { { api_key: "test-key" } }
  let(:provider) { described_class.new(**config) }

  describe "#client" do
    it "returns the Anthropic client instance" do
      expect(provider.client).to be_a(Anthropic::Client)
    end
  end

  describe "#models" do
    let(:mock_models_response) do
      mock_model_info_1 = double("ModelInfo", id: "claude-3-5-sonnet-latest")
      mock_model_info_2 = double("ModelInfo", id: "claude-3-haiku-20240307")

      double(
        "Page",
        data: [mock_model_info_1, mock_model_info_2],
        has_more: false,
        first_id: "claude-3-5-sonnet-latest",
        last_id: "claude-3-haiku-20240307"
      )
    end

    before do
      models_client = double("ModelsClient")
      allow_any_instance_of(Anthropic::Client).to receive(:models).and_return(
        models_client
      )
      allow(models_client).to receive(:list).and_return(mock_models_response)
    end

    it "returns an array of model IDs as strings" do
      expect(provider.models).to eq(
        %w[claude-3-5-sonnet-latest claude-3-haiku-20240307]
      )
    end
  end

  describe "#call" do
    let(:prompt) { "Test prompt" }
    let(:task) { "Test task" }
    let(:mock_response) do
      OpenStruct.new(
        content: [OpenStruct.new(text: '{"summary": "Test response"}')]
      )
    end

    before do
      messages_client = double("MessagesClient")
      allow_any_instance_of(Anthropic::Client).to receive(:messages).and_return(
        messages_client
      )
      allow(messages_client).to receive(:create).and_return(mock_response)
    end

    it "returns a hash with raw and parsed response" do
      response = provider.call(prompt, task)
      expect(response).to eq(
        {
          raw: '{"summary": "Test response"}',
          parsed: {
            "summary" => "Test response"
          }
        }
      )
    end

    context "when the response is not valid JSON" do
      let(:mock_response) do
        OpenStruct.new(content: [OpenStruct.new(text: "not valid json")])
      end

      it "returns raw response with nil parsed value" do
        response = provider.call(prompt, task)
        expect(response).to eq({ raw: "not valid json", parsed: nil })
      end
    end
  end

  describe "#model" do
    it "returns the default model when not specified" do
      expect(provider.model).to be_a(
        Lluminary::Models::Anthropic::Claude35Sonnet
      )
    end

    it "returns the specified model when provided in config" do
      model_class = double("ModelClass")
      model_instance = double("ModelInstance")

      allow(model_class).to receive(:new).and_return(model_instance)

      custom_provider =
        described_class.new(model: model_class, api_key: "test-key")

      expect(custom_provider.model).to eq(model_instance)
    end
  end
end
