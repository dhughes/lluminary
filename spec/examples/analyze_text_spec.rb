# frozen_string_literal: true
require "spec_helper"
require_relative "../../examples/analyze_text"

RSpec.describe AnalyzeText do
  let(:text) do
    "Ruby is a dynamic, open source programming language with a focus on simplicity and productivity. It has an elegant syntax that is natural to read and easy to write."
  end

  it "analyzes text" do
    result = described_class.call(text: text)
    expect(result.output.analysis).to be_a(String)
    expect(result.output.analysis).not_to be_empty
  end

  it "returns JSON response" do
    result = described_class.call(text: text)
    expect(result.output.raw_response).to be_a(String)
    expect { JSON.parse(result.output.raw_response) }.not_to raise_error
    json = JSON.parse(result.output.raw_response)
    expect(json).to have_key("analysis")
    expect(json["analysis"]).to eq(result.output.analysis)
  end
end
