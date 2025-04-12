require 'lluminary'

RSpec.describe Lluminary::Result do
  let(:raw_response) { "Test response" }
  let(:output) { { summary: "Test summary" } }
  let(:prompt) { "Test prompt" }
  let(:result) { described_class.new(raw_response: raw_response, output: output, prompt: prompt) }

  describe '#raw_response' do
    it 'returns the raw response' do
      expect(result.raw_response).to eq(raw_response)
    end
  end

  describe '#output' do
    it 'returns an OpenStruct with the output data' do
      expect(result.output).to be_a(OpenStruct)
      expect(result.output.summary).to eq(output[:summary])
    end

    it 'allows accessing output fields as methods' do
      expect(result.output.summary).to eq(output[:summary])
    end
  end

  describe '#prompt' do
    it 'returns the prompt' do
      expect(result.prompt).to eq(prompt)
    end
  end
end 