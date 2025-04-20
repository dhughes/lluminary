# frozen_string_literal: true
require "spec_helper"

RSpec.describe Lluminary::Providers::OpenAI do
  let(:config) { { api_key: "test-key" } }
  let(:provider) { described_class.new(**config) }

  describe "#client" do
    it "returns the OpenAI client instance" do
      expect(provider.client).to be_a(OpenAI::Client)
    end
  end

  describe "#models" do
    let(:mock_models_response) do
      {
        "object" => "list",
        "data" => [
          {
            "id" => "gpt-4",
            "object" => "model",
            "created" => 1_687_882_411,
            "owned_by" => "openai"
          },
          {
            "id" => "gpt-3.5-turbo",
            "object" => "model",
            "created" => 1_677_610_602,
            "owned_by" => "openai"
          }
        ]
      }
    end

    before do
      models_client = double("ModelsClient", list: mock_models_response)
      allow_any_instance_of(OpenAI::Client).to receive(:models).and_return(
        models_client
      )
    end

    it "returns the list of models from the API" do
      expect(provider.models).to eq(mock_models_response)
    end
  end

  describe "#call" do
    let(:prompt) { "Test prompt" }
    let(:task) { "Test task" }
    let(:mock_response) do
      {
        "choices" => [
          { "message" => { "content" => '{"summary": "Test response"}' } }
        ]
      }
    end

    before do
      allow_any_instance_of(OpenAI::Client).to receive(:chat).and_return(
        mock_response
      )
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
        { "choices" => [{ "message" => { "content" => "not valid json" } }] }
      end

      it "returns raw response with nil parsed value" do
        response = provider.call(prompt, task)
        expect(response).to eq({ raw: "not valid json", parsed: nil })
      end
    end
  end
end
