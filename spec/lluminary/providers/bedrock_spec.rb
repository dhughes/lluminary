# frozen_string_literal: true
require "spec_helper"
require "lluminary/providers/bedrock"

RSpec.describe Lluminary::Providers::Bedrock do
  let(:config) do
    {
      region: "us-east-1",
      access_key_id: "test-key",
      secret_access_key: "test-secret"
    }
  end
  let(:provider) { described_class.new(**config) }

  describe "#client" do
    it "returns the AWS Bedrock client instance" do
      expect(provider.client).to be_a(Aws::BedrockRuntime::Client)
    end
  end

  describe "#call" do
    let(:prompt) { "Test prompt" }
    let(:task) { "Test task" }
    let(:mock_response) do
      OpenStruct.new(
        output:
          OpenStruct.new(
            message:
              OpenStruct.new(
                content: [OpenStruct.new(text: '{"sentiment": "positive"}')]
              )
          )
      )
    end

    before do
      allow_any_instance_of(Aws::BedrockRuntime::Client).to receive(
        :converse
      ).and_return(mock_response)
    end

    it "returns a hash with raw and parsed response" do
      response = provider.call(prompt, task)
      expect(response).to eq(
        {
          raw: '{"sentiment": "positive"}',
          parsed: {
            "sentiment" => "positive"
          }
        }
      )
    end

    context "when the response is not valid JSON" do
      let(:mock_response) do
        OpenStruct.new(
          output:
            OpenStruct.new(
              message:
                OpenStruct.new(
                  content: [OpenStruct.new(text: "not valid json")]
                )
            )
        )
      end

      it "returns raw response with nil parsed value" do
        response = provider.call(prompt, task)
        expect(response).to eq({ raw: "not valid json", parsed: nil })
      end
    end

    context "when the response content is nil" do
      let(:mock_response) do
        OpenStruct.new(
          output: OpenStruct.new(message: OpenStruct.new(content: nil))
        )
      end

      it "returns nil for both raw and parsed values" do
        response = provider.call(prompt, task)
        expect(response).to eq({ raw: nil, parsed: nil })
      end
    end

    context "when the response content array is empty" do
      let(:mock_response) do
        OpenStruct.new(
          output: OpenStruct.new(message: OpenStruct.new(content: []))
        )
      end

      it "returns nil for both raw and parsed values" do
        response = provider.call(prompt, task)
        expect(response).to eq({ raw: nil, parsed: nil })
      end
    end
  end
end
