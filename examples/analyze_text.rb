# frozen_string_literal: true
require_relative "config"

# A task that analyzes text using LLM to extract structured information.
# Takes text input and returns a structured analysis based on a predefined schema.
class AnalyzeText < Lluminary::Task
  use_provider :anthropic

  input_schema { string :text }

  output_schema { string :analysis }

  def task_prompt
    "Analyze the following text and provide a brief thematic analysis:\n\n#{text}"
  end
end

if __FILE__ == $PROGRAM_NAME
  text = <<~TEXT
    In a quiet village nestled between rolling hills and whispering pines, there lived a buff-colored cat named Fig. His coat shimmered like warm sand in the sun, and he spent his days stretched across stone walls and window ledges, a golden blur of contentment. Though the village children adored him and his elderly owner gave him all the cream he could want, Fig often found himself gazing beyond the fields, wondering if life held something more than naps and the occasional sparrow chase. One morning, as the dew still clung to the grass, Fig slipped out through the garden gate and padded off toward the unknown.

    His journey led him through winding forest paths, across clattering town squares, and beneath starlit skies. He met an old alley cat who spoke of distant ports and salt-stung winds, a contemplative owl who asked questions instead of offering answers, and a blind dog who described beauty through smells and sounds alone. Each encounter etched something into Fig's mind—a sense that life was richer and deeper than he'd imagined. It wasn't about being safe or certain, but about tasting each moment, opening yourself to others, and recognizing the wonder tucked inside the ordinary.

    Eventually, Fig returned to his village, not with the swagger of a conquering hero, but with the calm poise of someone who had seen the world and understood it a little better. He resumed his favorite perch by the window, basking in the morning light, but now he listened closer to birdsong, lingered longer with the children, and purred not just for pleasure, but in gratitude. The meaning of life, Fig had learned, wasn't a secret to be discovered—it was in every step, every scent, every shared glance. And from that day on, the little buff-colored cat lived not just comfortably, but deeply.
  TEXT

  puts "#> Running AnalyzeText example"

  result = AnalyzeText.call(text: text)

  puts result.output.analysis
end
