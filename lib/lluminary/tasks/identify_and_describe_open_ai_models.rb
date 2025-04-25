# frozen_string_literal: true

module Lluminary
  module Tasks
    class IdentifyAndDescribeOpenAiModels < Lluminary::Task
      use_provider :bedrock, model: Lluminary::Models::Bedrock::AmazonNovaProV1

      input_schema do
        array :models, description: "List of OpenAI models" do
          string
        end
      end

      output_schema do
        array :root_models,
              description: "List of root models and their versions" do
          hash do
            string :name,
                   description:
                     "The root name of the model. For example, 'gpt-4' or 'gpt-4o'"
            array :versions,
                  description:
                    "List of versions of the root model. For example, '0125-preview' or '0613' or '2024-04-09'" do
              string
            end
          end
        end
      end

      def task_prompt
        <<~PROMPT
          You are an expert in OpenAI models. You will be given a list of OpenAI models and asked to group them together by the "root" model type and capability and list the various versions of the root model.

          Keep in mind that some "root" models have names with the same root name but different capabilities. For example, "gpt-4o" and "gpt-4o-audio" are distinct models, since they have different capabilities and each has their own versions.
          
          "gpt-4.5-preview" and "gpt-4.5-preview-2025-02-27" are examples of the "gpt-4.5" root model. There are two versions of the "gpt-4.5" root model: "preview" and "preview-2025-02-27".

          Given the following list of models, please group them together by the "root" model type and list their versions. 

          Your response will be used to generate code that will make use of the models and their verisons. 

          It's critical that you represent every model and version from the following list in your response. Any model or version that is missed will be excluded from subsequent code generation and that will make them very, very sad. We don't want any sad models.

          DO NOT include any other models or versions in your response other than those from ones listed below. Use your expertise in OpenAI models to distinguish between different "root" models and their versions.

          Models: #{models.join(", ")}
        PROMPT
      end
    end
  end
end
