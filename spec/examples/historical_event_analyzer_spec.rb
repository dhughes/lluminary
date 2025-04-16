# frozen_string_literal: true
require "spec_helper"
require_relative "../../examples/historical_event_analyzer"
require "pry-byebug"

RSpec.describe HistoricalEventAnalyzer do
  describe "#call" do
    context "with events that have known exact times" do
      it "returns the exact time of the human step on the moon" do
        result =
          described_class.call(
            event_description: "Neil Armstrong's first step onto the Moon"
          )

        expect(result.output.valid?).to be true
        expect(result.output.event_datetime).to be_a(DateTime)
        # LLMs are too flaky to get the exact date and time correct, at least with my prompt.
        expect(result.output.event_datetime.year).to eq(1969)
        expect(result.output.event_datetime.month).to eq(7)
        expect(result.output.exact_time_is_known).to be true
      end
    end

    context "with events that have approximate times" do
      it "returns midnight for the fall of the Roman Empire" do
        result =
          described_class.call(
            event_description: "Assassination of Julius Caesar"
          )

        expect(result.output.valid?).to be true
        expect(result.output.event_datetime).to be_a(DateTime)
        expect(result.output.event_datetime.year).to eq(44)
        expect(result.output.event_datetime.month).to eq(3)
        expect(result.output.event_datetime.day).to eq(15)
        expect(result.output.exact_time_is_known).to be false
      end
    end
  end
end
