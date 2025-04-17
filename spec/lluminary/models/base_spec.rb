# frozen_string_literal: true
require "spec_helper"

RSpec.describe Lluminary::Models::Base do
  describe "#compatible_with?" do
    it "raises NotImplementedError" do
      expect { described_class.new.compatible_with?(:openai) }.to raise_error(
        NotImplementedError
      )
    end
  end
end
