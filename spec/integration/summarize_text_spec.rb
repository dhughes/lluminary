require 'spec_helper'
require_relative '../../examples/summarize_text'

RSpec.describe SummarizeText do
  let(:text) { "Ruby is a dynamic, open source programming language with a focus on simplicity and productivity. It has an elegant syntax that is natural to read and easy to write." }

  it "summarizes text" do
    result = described_class.call(text: text)
    expect(result.output.summary).to be_a(String)
    expect(result.output.summary).not_to be_empty
  end

  it "returns JSON response" do
    result = described_class.call(text: text)
    expect(result.raw_response).to be_a(String)
    expect { JSON.parse(result.raw_response) }.not_to raise_error
    json = JSON.parse(result.raw_response)
    expect(json).to have_key("summary")
    expect(json["summary"]).to eq(result.output.summary)
  end
end 