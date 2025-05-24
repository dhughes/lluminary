# frozen_string_literal: true
require "spec_helper"

RSpec.describe Lluminary::Providers::Google do
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
            "id" => "models/gemini-2.0-flash",
            "object" => "model",
            "owned_by" => "google"
          },
          {
            "id" => "models/gemini-1.5-pro",
            "object" => "model",
            "owned_by" => "google"
          }
        ]
      }
    end

    before do
      allow_any_instance_of(OpenAI::Client).to receive(:models).and_return(
        double("ModelsClient", list: mock_models_response)
      )
    end

    it "returns an array of model IDs as strings with the 'models/' prefix removed" do
      expect(provider.models).to eq(%w[gemini-2.0-flash gemini-1.5-pro])
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
