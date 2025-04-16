# frozen_string_literal: true
require_relative "config"

class HistoricalEventAnalyzer < Lluminary::Task
  use_provider :bedrock, model_id: "anthropic.claude-instant-v1"

  input_schema do
    string :event_description,
           description: "A description of the historical event to analyze"

    validates :event_description, presence: true
  end

  output_schema do
    datetime :event_datetime,
             description:
               "The exact date and time when the event occurred in the UTC timezone. If it is known, use the exact time to the minute, otherwise use midnight. Do not guess."
    boolean :exact_time_is_known,
            description:
              "Whether the exact time to the minute of the event is known and well documented. If the exact time is not known, return false."

    validates :event_datetime, presence: true
    validates :exact_time_is_known, inclusion: { in: [true, false] }
  end

  private

  def task_prompt
    <<~PROMPT
      Analyze the following historical event and determine the date and time it occurred.
      Consider the time precision to the minute (not seconds). 
      Please also indicate whether the exact time of the event is known with certainty.
      
      Event: #{event_description}
    PROMPT
  end
end

# Example usage
if __FILE__ == $PROGRAM_NAME
  puts "#> Running HistoricalEventAnalyzer example"

  result =
    HistoricalEventAnalyzer.call(
      event_description: "Neil Armstrong's first step onto the Moon"
    )

  puts "##> Input"
  puts result.input
  puts result.input.valid?

  puts "##> Generated prompt"
  puts result.prompt

  puts "##> Output"
  puts result.output
  puts "Output valid?: #{result.output.valid?}"
  puts result.output.errors.full_messages

  puts "Date/Time: #{result.output.event_datetime}"
  puts "Date/Time type: #{result.output.event_datetime.class}"
  puts "Exact time known: #{result.output.exact_time_is_known}"

  result =
    HistoricalEventAnalyzer.call(
      event_description: "Assassination of Julius Caesar"
    )

  puts "##> Input"
  puts result.input
  puts result.input.valid?

  puts "##> Generated prompt"
  puts result.prompt

  puts "##> Output"
  puts result.output
  puts "Output valid?: #{result.output.valid?}"
  puts result.output.errors.full_messages
  puts "Date/Time: #{result.output.event_datetime}"
  puts "Date/Time type: #{result.output.event_datetime.class}"
  puts "Exact time known: #{result.output.exact_time_is_known}"
end
