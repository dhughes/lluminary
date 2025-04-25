# frozen_string_literal: true

module Lluminary
  module Tasks
    class DescribeOpenAiModel < Lluminary::Task
      use_provider :openai

      input_schema do
        string :model, description: "The OpenAI model to describe"
      end

      # {
      #   "id": "gpt-4o-2024-11-20",
      #   "family": "gpt-4o",
      #   "variant": "standard",
      #   "release_date": "2024-11-20",
      #   "status": "GA",
      #   "inputs": {"text": true, "image": true, "audio": false},
      #   "outputs": {"text": true, "audio": false}
      # }

      output_schema do
        hash :model_description, description: "The description of the model" do
          string :id,
                 description:
                   "The full OpenAI API model ID being described. EG: 'gpt-4o-2024-11-20'"
          string :family,
                 description:
                   "The OpenAI model family. EG: 'gpt-4o' or 'gpt-4.1-mini'"
          string :variant, description: "The OpenAI model variant"
          string :release_date,
                 description: "The model's release date, if known."
          string :status,
                 description: "The OpenAI model status. EG: GA or preview"
          hash :inputs, description: "The model's inputs" do
            boolean :text, description: "Whether the model can process text"
            boolean :image, description: "Whether the model can process images"
            boolean :audio, description: "Whether the model can process audio"
            string :other_inputs,
                   description: "Other inputs the model can process"
          end
          hash :outputs, description: "The model's outputs" do
            boolean :text, description: "Whether the model can output text"
            boolean :image, description: "Whether the model can output images"
            boolean :audio, description: "Whether the model can output audio"
            string :other_outputs,
                   description: "Other outputs the model can return"
          end
        end
      end

      def task_prompt
        <<~PROMPT
          You are an expert in OpenAI models. You will be given a model ID and asked to describe the model using structured data.

          Model ID: #{input.model}
        PROMPT
      end
    end
  end
end
