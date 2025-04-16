# frozen_string_literal: true
require "lluminary"

RSpec.describe Lluminary::Providers::Base do
  describe "#initialize" do
    it "accepts configuration options" do
      config = { api_key: "test_key", model: "test_model" }
      provider = described_class.new(**config)
      expect(provider.config).to eq(config)
    end
  end

  describe "#call" do
    it "raises NotImplementedError" do
      expect do
        described_class.new.call("test", double("Task"))
      end.to raise_error(NotImplementedError)
    end
  end
end
