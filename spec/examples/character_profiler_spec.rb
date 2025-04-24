# frozen_string_literal: true
require "spec_helper"
require_relative "../../examples/character_profiler"

RSpec.describe CharacterProfiler do
  let(:sample_text) { <<~TEXT }
    Eliza Montenegro was not the kind of person who made a grand entrance, despite her striking appearance. 
    At 5'9" with curly auburn hair that framed an angular face, she preferred tailored blazers and vintage boots that had seen better days.
    
    Her colleagues at the research lab respected her brilliant mind but found her difficult to read. She spoke rarely in meetings, 
    but when she did, everyone listened. The only time she seemed to lower her guard was around Dr. Chen, her mentor of fifteen years,
    or when discussing her passion project: developing affordable water filtration systems for remote villages like the one her grandmother grew up in.
  TEXT

  describe "input validation" do
    it "accepts valid text input" do
      expect { described_class.call!(text: sample_text) }.not_to raise_error
    end

    it "requires text to be present" do
      expect do described_class.call!(text: "") end.to raise_error(
        Lluminary::ValidationError
      )
    end
  end

  describe "output validation" do
    let(:result) { described_class.call(text: sample_text) }

    it "returns a character profile hash" do
      character_profile = result.output.character_profile

      expect(character_profile).to be_a(Hash)
    end

    it "includes basic profile fields" do
      profile = result.output.character_profile

      expect(profile["name"]).to be_a(String)
      expect(profile["personality"]).to be_a(String)
      expect(profile["complexity_score"]).to be_a(Float)
    end

    it "includes an appearance hash with required fields" do
      appearance = result.output.character_profile["appearance"]

      expect(appearance).to be_a(Hash)
      expect(appearance["physical_traits"]).to be_a(String)
      expect(appearance["style"]).to be_a(String)
    end

    it "includes an array of motivations" do
      motivations = result.output.character_profile["motivations"]

      expect(motivations).to be_an(Array)
      expect(motivations).to all(be_a(String)) unless motivations.empty?
    end

    it "includes a relationships hash with allies and adversaries" do
      relationships = result.output.character_profile["relationships"]

      expect(relationships).to be_a(Hash)

      expect(relationships["allies"]).to be_an(Array)
      expect(relationships["allies"]).to all(be_a(String))

      expect(relationships["adversaries"]).to be_an(Array)
      expect(relationships["adversaries"]).to be_empty
    end

    it "has a complexity score between 0 and 1" do
      score = result.output.character_profile["complexity_score"]
      expect(score).to be >= 0.0
      expect(score).to be <= 1.0
    end
  end

  describe "prompt generation" do
    let(:result) { described_class.call(text: sample_text) }

    it "includes the text in the prompt" do
      expect(result.prompt).to include(sample_text)
    end
  end
end
