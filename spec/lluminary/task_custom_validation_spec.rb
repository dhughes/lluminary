# frozen_string_literal: true
require "spec_helper"

RSpec.describe "Task custom validations" do
  # Test task classes
  class TaskWithInputValidation < Lluminary::Task
    use_provider :test

    input_schema do
      string :text
      integer :min_length, description: "Minimum word length to count"

      validate :validate_input_min_length
    end

    output_schema { integer :word_count }

    def validate_input_min_length
      min_length_value = @input.attributes["min_length"]
      if min_length_value && min_length_value <= 0
        @input.errors.add(:min_length, "must be positive")
      end
    end

    def task_prompt
      "Count words in: #{text}"
    end
  end

  class TaskWithOutputValidation < Lluminary::Task
    use_provider :test

    input_schema { string :text }

    output_schema do
      string :sentiment,
             description: "Sentiment of the text (positive, negative, neutral)"
      integer :confidence, description: "Confidence score from 0-100"

      validate :validate_confidence_range
    end

    def validate_confidence_range
      confidence_value = @output.attributes["confidence"]
      if confidence_value && (confidence_value < 0 || confidence_value > 100)
        @output.errors.add(:confidence, "must be between 0 and 100")
      end
    end

    def task_prompt
      "Analyze sentiment of: #{text}"
    end
  end

  class TaskWithBothValidations < Lluminary::Task
    use_provider :test

    input_schema do
      string :text
      array :hashtags, description: "Hashtags to analyze" do
        string
      end

      validate :validate_hashtags
    end

    output_schema do
      array :relevant_hashtags do
        string
      end
      hash :analysis do
        string :top_hashtag
        integer :count
      end

      validate :validate_top_hashtag
    end

    def validate_hashtags
      hashtags_value = @input.attributes["hashtags"]
      if hashtags_value && hashtags_value.any? &&
           !hashtags_value.all? { |h| h.start_with?("#") }
        @input.errors.add(:hashtags, "must all start with # symbol")
      end
    end

    def validate_top_hashtag
      top_hashtag = @output.attributes.dig("analysis", "top_hashtag")
      relevant_hashtags = @output.attributes["relevant_hashtags"]
      if top_hashtag && relevant_hashtags &&
           !relevant_hashtags.include?(top_hashtag)
        @output.errors.add(
          :analysis,
          "top hashtag must be in the relevant_hashtags list"
        )
      end
    end

    def task_prompt
      "Analyze hashtags in: #{text}"
    end
  end

  # Override Test provider for predictable responses
  class TestProvider < Lluminary::Providers::Test
    def initialize(response_data = nil)
      @response_data = response_data || {}
    end

    def call(prompt, task)
      if @response_data[task.class.name]
        @response_data[task.class.name]
      else
        { raw: "{}", parsed: {} }
      end
    end
  end

  describe "input validations" do
    before do
      # Reset the provider to use our test provider
      TaskWithInputValidation.provider = TestProvider.new
    end

    it "validates input with custom methods" do
      task = TaskWithInputValidation.new(text: "Hello world", min_length: 0)
      expect(task.valid?).to be false
      expect(task.input.errors.full_messages).to include(
        "Min length must be positive"
      )
    end

    it "accepts valid input" do
      task = TaskWithInputValidation.new(text: "Hello world", min_length: 3)
      expect(task.valid?).to be true
      expect(task.input.errors.full_messages).to be_empty
    end

    it "rejects invalid input in call" do
      result = TaskWithInputValidation.call(text: "Hello world", min_length: -5)
      expect(result.input.valid?).to be false
      expect(result.output).to be_nil
    end
  end

  describe "output validations" do
    before do
      # Setup test provider with custom responses
      responses = {
        "TaskWithOutputValidation" => {
          raw: '{"sentiment": "positive", "confidence": 150}',
          parsed: {
            "sentiment" => "positive",
            "confidence" => 150 # Invalid: over 100
          }
        }
      }
      TaskWithOutputValidation.provider = TestProvider.new(responses)
    end

    it "validates output with custom methods" do
      result = TaskWithOutputValidation.call(text: "I love this product!")
      expect(result.output.valid?).to be false
      expect(result.output.errors.full_messages).to include(
        "Confidence must be between 0 and 100"
      )
    end

    it "works with valid output" do
      # Patch the provider with valid data for this test
      valid_responses = {
        "TaskWithOutputValidation" => {
          raw: '{"sentiment": "positive", "confidence": 95}',
          parsed: {
            "sentiment" => "positive",
            "confidence" => 95 # Valid: between 0-100
          }
        }
      }
      TaskWithOutputValidation.provider = TestProvider.new(valid_responses)

      result = TaskWithOutputValidation.call(text: "I love this product!")
      expect(result.output.valid?).to be true
      expect(result.output.errors.full_messages).to be_empty
      expect(result.output.sentiment).to eq("positive")
      expect(result.output.confidence).to eq(95)
    end
  end

  describe "both input and output validations" do
    before do
      # Setup test provider with custom responses
      responses = {
        "TaskWithBothValidations" => {
          raw:
            '{"relevant_hashtags": ["#ruby", "#rails"], "analysis": {"top_hashtag": "#javascript", "count": 5}}',
          parsed: {
            "relevant_hashtags" => %w[#ruby #rails],
            "analysis" => {
              "top_hashtag" => "#javascript", # Invalid: not in relevant_hashtags
              "count" => 5
            }
          }
        }
      }
      TaskWithBothValidations.provider = TestProvider.new(responses)
    end

    it "validates input with custom methods" do
      task =
        TaskWithBothValidations.new(
          text: "Hello world",
          hashtags: %w[ruby rails]
        )
      expect(task.valid?).to be false
      expect(task.input.errors.full_messages).to include(
        "Hashtags must all start with # symbol"
      )
    end

    it "validates output with custom methods" do
      # Input is valid for this test
      result =
        TaskWithBothValidations.call(
          text: "Hello world",
          hashtags: %w[#ruby #rails]
        )
      expect(result.output.valid?).to be false
      expect(result.output.errors.full_messages).to include(
        "Analysis top hashtag must be in the relevant_hashtags list"
      )
    end

    it "works with valid input and output" do
      # Patch the provider with valid data for this test
      valid_responses = {
        "TaskWithBothValidations" => {
          raw:
            '{"relevant_hashtags": ["#ruby", "#rails"], "analysis": {"top_hashtag": "#ruby", "count": 5}}',
          parsed: {
            "relevant_hashtags" => %w[#ruby #rails],
            "analysis" => {
              "top_hashtag" => "#ruby", # Valid: in relevant_hashtags
              "count" => 5
            }
          }
        }
      }
      TaskWithBothValidations.provider = TestProvider.new(valid_responses)

      result =
        TaskWithBothValidations.call(
          text: "Hello world",
          hashtags: %w[#ruby #rails]
        )
      expect(result.input.valid?).to be true
      expect(result.output.valid?).to be true
      expect(result.output.relevant_hashtags).to eq(%w[#ruby #rails])
      expect(result.output.analysis["top_hashtag"]).to eq("#ruby")
    end
  end
end
