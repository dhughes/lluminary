require 'spec_helper'

RSpec.describe Luminary::Providers::OpenAI do
  let(:api_key) { ENV['OPENAI_API_KEY'] }
  let(:provider) { described_class.new(api_key: api_key) }
  let(:task) { double('Task') }

  it "successfully calls the OpenAI API" do
    result = provider.call("Please respond with a JSON object containing a greeting field.", task)
    expect(result).to be_an(Array)
    expect(result.first).to be_a(String)
    expect(result.last).to be_a(Hash)
  end
end 