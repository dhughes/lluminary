# frozen_string_literal: true
require "spec_helper"

# The following is an example of our goals for the output when describing fields in the schema:
#
# # user_profile
# Description: A user's complete profile
# Type: object
# Example: {
#   "name": "your name here",
#   "age": 0,
#   "preferences": {
#     "theme": "your theme here",
#     "notifications_enabled": true
#   }
# }
#
# # name
# Description: A person's full name
# Type: string
# Example: "your name here"
#
# # age
# Type: integer
# Example: 0
#
# # preferences
# Description: User's system preferences
# Type: object
# Example: {
#   "theme": "your theme here",
#   "notifications_enabled": true
# }
#
# # preferences.theme
# Description: The UI color theme
# Type: string
# Example: "your theme here"
#
# # preferences.notifications_enabled
# Type: boolean
# Example: true
#
# # security
# Description: Security and authentication settings
# Type: object
# Example: {
#   "credentials": {
#     "last_login": "2024-01-01T12:00:00+00:00"
#   }
# }
#
# # security.credentials
# Type: object
# Example: {
#   "last_login": "2024-01-01T12:00:00+00:00"
# }
#
# # security.credentials.last_login
# Type: datetime in ISO8601 format
# Description: Most recent successful login
# Example: "2024-01-01T12:00:00+00:00"
#
# # tags
# Description: User's associated tags
# Type: array of string
# Example: ["first tag", "second tag"]
#
# # roles
# Description: User's system roles
# Type: array of objects
# Example: [
#   {
#     "name": "your name here",
#     "permissions": ["first permission", "second permission"]
#   },
#   {
#     "name": "your name here",
#     "permissions": ["first permission", "second permission"]
#   }
# ]
#
# # roles[].name
# Description: Name of the role
# Type: string
# Example: "your name here"
#
# # roles[].permissions
# Description: Permissions granted by this role
# Type: array of strings
# Example: ["first permission", "second permission"]
#
# # matrix
# Description: A 2D grid of numbers
# Type: array of arrays
# Example: [[1, 2, 3], [4, 5, 6]]
#
# # settings
# Description: User configuration settings
# Type: object
# Example: {
#   "theme": "your theme here",
#   "favorites": ["first favorite", "second favorite"],
#   "notifications": {
#     "email": true,
#     "channels": ["first channel", "second channel"]
#   }
# }
#
# # settings.favorites
# Description: User's favorite items
# Type: array of strings
# Example: ["first favorite", "second favorite"]
#
# # settings.notifications
# Description: Notification preferences
# Type: object
# Example: {
#   "email": true,
#   "channels": ["first channel", "second channel"]
# }
#
# # settings.notifications.channels
# Description: Notification channels to use
# Type: array of strings
# Example: ["first channel", "second channel"]

RSpec.describe Lluminary::Models::Base do
  let(:model) { described_class.new }

  describe "#compatible_with?" do
    it "raises NotImplementedError" do
      expect { model.compatible_with?(:openai) }.to raise_error(
        NotImplementedError
      )
    end
  end

  describe "#name" do
    it "raises NotImplementedError" do
      expect { model.name }.to raise_error(NotImplementedError)
    end
  end

  describe "#format_prompt" do
    let(:task_class) do
      Class.new(Lluminary::Task) do
        def task_prompt
          "Test prompt"
        end
      end
    end

    let(:task) { task_class.new }

    context "with simple field types" do
      context "with string field type" do
        before do
          task_class.output_schema do
            string :name, description: "The person's name"
          end
        end

        it "formats string field description correctly" do
          prompt = model.format_prompt(task)

          expected_description = <<~DESCRIPTION.chomp
            # name
            Description: The person's name
            Type: string
            Example: "your name here"
          DESCRIPTION

          expect(prompt).to include(expected_description)
        end
      end

      context "with integer field type" do
        before do
          task_class.output_schema do
            integer :age, description: "The person's age"
          end
        end

        it "formats integer field description correctly" do
          prompt = model.format_prompt(task)

          expected_description = <<~DESCRIPTION.chomp
            # age
            Description: The person's age
            Type: integer
            Example: 0
          DESCRIPTION

          expect(prompt).to include(expected_description)
        end
      end

      context "with boolean field type" do
        before do
          task_class.output_schema do
            boolean :active, description: "Whether the person is active"
          end
        end

        it "formats boolean field description correctly" do
          prompt = model.format_prompt(task)

          expected_description = <<~DESCRIPTION.chomp
            # active
            Description: Whether the person is active
            Type: boolean
            Example: true
          DESCRIPTION

          expect(prompt).to include(expected_description)
        end
      end

      context "with float field type" do
        before do
          task_class.output_schema do
            float :score, description: "The person's score"
          end
        end

        it "formats float field description correctly" do
          prompt = model.format_prompt(task)

          expected_description = <<~DESCRIPTION.chomp
            # score
            Description: The person's score
            Type: float
            Example: 0.0
          DESCRIPTION

          expect(prompt).to include(expected_description)
        end
      end

      context "with datetime field type" do
        before do
          task_class.output_schema do
            datetime :created_at, description: "When the person was created"
          end
        end

        it "formats datetime field description correctly" do
          prompt = model.format_prompt(task)

          expected_description = <<~DESCRIPTION.chomp
            # created_at
            Description: When the person was created
            Type: datetime in ISO8601 format
            Example: "2024-01-01T12:00:00+00:00"
          DESCRIPTION

          expect(prompt).to include(expected_description)
        end
      end
    end

    context "with array fields" do
      context "with simple array of strings" do
        before do
          task_class.output_schema do
            array :tags, description: "List of tags" do
              string
            end
          end
        end

        it "formats array of strings field description correctly" do
          prompt = model.format_prompt(task)

          expected_description = <<~DESCRIPTION.chomp
            # tags
            Description: List of tags
            Type: array of strings
            Example: ["first tag","second tag"]
          DESCRIPTION

          expect(prompt).to include(expected_description)
        end
      end

      context "with array of floats" do
        before do
          task_class.output_schema do
            array :scores, description: "List of scores" do
              float
            end
          end
        end

        it "formats array of floats field description correctly" do
          prompt = model.format_prompt(task)

          expected_description = <<~DESCRIPTION.chomp
            # scores
            Description: List of scores
            Type: array of floats
            Example: [1.0,2.0,3.0]
          DESCRIPTION

          expect(prompt).to include(expected_description)
        end
      end

      context "with array of datetimes" do
        before do
          task_class.output_schema do
            array :dates, description: "List of important dates" do
              datetime
            end
          end
        end

        it "formats array of datetimes field description correctly" do
          prompt = model.format_prompt(task)

          expected_description = <<~DESCRIPTION.chomp
            # dates
            Description: List of important dates
            Type: array of datetimes in ISO8601 format
            Example: ["2024-01-01T12:00:00+00:00","2024-01-02T12:00:00+00:00"]
          DESCRIPTION

          expect(prompt).to include(expected_description)
        end
      end

      context "with 2D array (matrix) with descriptions" do
        before do
          task_class.output_schema do
            array :matrix, description: "2D array of numbers" do
              array description: "1D array of numbers" do
                integer description: "A number"
              end
            end
          end
        end

        it "formats 2D array field description correctly" do
          prompt = model.format_prompt(task)

          expected_description = <<~DESCRIPTION.chomp
            # matrix
            Description: 2D array of numbers
            Type: array of arrays
            Example: [[1,2,3],[1,2,3]]

            # matrix[]
            Description: 1D array of numbers
            Type: array of integers
            Example: [1,2,3]

            # matrix[][]
            Description: A number
            Type: integer
            Example: 0
          DESCRIPTION

          expect(prompt).to include(expected_description)
        end
      end

      context "with 2D array (matrix) with some descriptions" do
        before do
          task_class.output_schema do
            array :matrix, description: "2D array of numbers" do
              array { integer description: "A number" }
            end
          end
        end

        it "formats 2D array field description correctly" do
          prompt = model.format_prompt(task)

          expected_description = <<~DESCRIPTION.chomp
            # matrix
            Description: 2D array of numbers
            Type: array of arrays
            Example: [[1,2,3],[1,2,3]]

            # matrix[]
            Type: array of integers
            Example: [1,2,3]

            # matrix[][]
            Description: A number
            Type: integer
            Example: 0
          DESCRIPTION

          expect(prompt).to include(expected_description)
        end
      end

      context "with 3D array (cube)" do
        before do
          task_class.output_schema do
            array :cube, description: "3D array of strings" do
              array do
                array description: "1D array" do
                  string
                end
              end
            end
          end
        end

        it "formats 3D array field description correctly" do
          prompt = model.format_prompt(task)

          expected_description = <<~DESCRIPTION.chomp
            # cube
            Description: 3D array of strings
            Type: array of arrays
            Example: [[["first item","second item"],["first item","second item"]],[["first item","second item"],["first item","second item"]]]

            # cube[]
            Type: array of arrays
            Example: [["first item","second item"],["first item","second item"]]

            # cube[][]
            Description: 1D array
            Type: array of strings
            Example: ["first item","second item"]

            # cube[][][]
            Type: string
            Example: "first item"
          DESCRIPTION

          expect(prompt).to include(expected_description)
        end
      end

      context "with array containing hash" do
        before do
          task_class.output_schema do
            array :contacts, description: "List of contacts" do
              hash { string :name, description: "Contact name" }
            end
          end
        end

        it "formats array of hashes field description correctly" do
          prompt = model.format_prompt(task)

          expected_description = <<~DESCRIPTION.chomp
            # contacts
            Description: List of contacts
            Type: array of objects
            Example: [{"name":"your name here"},{"name":"your name here"}]

            # contacts[].name
            Description: Contact name
            Type: string
            Example: "your name here"
          DESCRIPTION

          expect(prompt).to include(expected_description)
        end
      end
    end

    context "with hash fields" do
      context "with simple hash with one field" do
        before do
          task_class.output_schema do
            hash :person do
              string :name, description: "The person's name"
            end
          end
        end

        it "formats hash field description correctly" do
          prompt = model.format_prompt(task)

          expected_description = <<~DESCRIPTION.chomp
            # person
            Type: object
            Example: {"name":"your name here"}

            # person.name
            Description: The person's name
            Type: string
            Example: "your name here"
          DESCRIPTION

          expect(prompt).to include(expected_description)
        end
      end

      context "with hash with two fields (one with description)" do
        before do
          task_class.output_schema do
            hash :person, description: "A person" do
              string :name, description: "The person's name"
              integer :age
            end
          end
        end

        it "formats hash field descriptions correctly" do
          prompt = model.format_prompt(task)

          expected_description = <<~DESCRIPTION.chomp
            # person
            Description: A person
            Type: object
            Example: {"name":"your name here","age":0}

            # person.name
            Description: The person's name
            Type: string
            Example: "your name here"

            # person.age
            Type: integer
            Example: 0
          DESCRIPTION

          expect(prompt).to include(expected_description)
        end
      end

      context "with hash containing datetime field" do
        before do
          task_class.output_schema do
            hash :event, description: "An event" do
              string :title
              datetime :scheduled_at, description: "When the event is scheduled"
            end
          end
        end

        it "formats hash with datetime field description correctly" do
          prompt = model.format_prompt(task)

          expected_description = <<~DESCRIPTION.chomp
            # event
            Description: An event
            Type: object
            Example: {"title":"your title here","scheduled_at":"2024-01-01T12:00:00+00:00"}

            # event.title
            Type: string
            Example: "your title here"

            # event.scheduled_at
            Description: When the event is scheduled
            Type: datetime in ISO8601 format
            Example: "2024-01-01T12:00:00+00:00"
          DESCRIPTION

          expect(prompt).to include(expected_description)
        end
      end

      context "with hash containing array field" do
        before do
          task_class.output_schema do
            hash :user, description: "A user profile" do
              string :name, description: "The person's name"
              array :tags, description: "User tags" do
                string
              end
            end
          end
        end

        it "formats hash with array field description correctly" do
          prompt = model.format_prompt(task)

          expected_description = <<~DESCRIPTION.chomp
            # user
            Description: A user profile
            Type: object
            Example: {"name":"your name here","tags":["first tag","second tag"]}

            # user.name
            Description: The person's name
            Type: string
            Example: "your name here"

            # user.tags
            Description: User tags
            Type: array of strings
            Example: ["first tag","second tag"]
          DESCRIPTION

          expect(prompt).to include(expected_description)
        end
      end

      context "with nested hashes (mixed descriptions)" do
        before do
          task_class.output_schema do
            hash :person, description: "A person profile" do
              string :name, description: "The person's name"
              integer :age
              hash :address do
                string :street, description: "Street name"
                string :city
                string :country
              end
              hash :preferences, description: "User preferences" do
                boolean :notifications
                hash :theme do
                  string :color, description: "Theme color"
                  boolean :dark_mode
                end
              end
            end
          end
        end

        it "formats nested hash fields correctly with mixed descriptions" do
          prompt = model.format_prompt(task)

          expected_description = <<~DESCRIPTION.chomp
            # person
            Description: A person profile
            Type: object
            Example: {"name":"your name here","age":0,"address":{"street":"your street here","city":"your city here","country":"your country here"},"preferences":{"notifications":true,"theme":{"color":"your color here","dark_mode":true}}}

            # person.name
            Description: The person's name
            Type: string
            Example: "your name here"

            # person.age
            Type: integer
            Example: 0

            # person.address
            Type: object
            Example: {"street":"your street here","city":"your city here","country":"your country here"}

            # person.address.street
            Description: Street name
            Type: string
            Example: "your street here"

            # person.address.city
            Type: string
            Example: "your city here"

            # person.address.country
            Type: string
            Example: "your country here"

            # person.preferences
            Description: User preferences
            Type: object
            Example: {"notifications":true,"theme":{"color":"your color here","dark_mode":true}}

            # person.preferences.notifications
            Type: boolean
            Example: true

            # person.preferences.theme
            Type: object
            Example: {"color":"your color here","dark_mode":true}

            # person.preferences.theme.color
            Description: Theme color
            Type: string
            Example: "your color here"

            # person.preferences.theme.dark_mode
            Type: boolean
            Example: true
          DESCRIPTION

          expect(prompt).to include(expected_description)
        end
      end
    end

    context "with validations" do
      context "presence validation" do
        before do
          task_class.output_schema do
            string :name, description: "The person's name"
            validates :name, presence: true
          end
        end

        it "includes presence validation in field description" do
          prompt = model.format_prompt(task)

          expected_description = <<~DESCRIPTION.chomp
            # name
            Description: The person's name
            Type: string
            Validations: must be present
            Example: "your name here"
          DESCRIPTION

          expect(prompt).to include(expected_description)
        end
      end

      context "inclusion validation" do
        before do
          task_class.output_schema do
            string :status, description: "The status"
            validates :status, inclusion: { in: %w[active inactive] }
          end
        end

        it "includes inclusion validation in field description" do
          prompt = model.format_prompt(task)

          expected_description = <<~DESCRIPTION.chomp
            # status
            Description: The status
            Type: string
            Validations: must be one of: active, inactive
            Example: "your status here"
          DESCRIPTION

          expect(prompt).to include(expected_description)
        end
      end

      context "exclusion validation" do
        before do
          task_class.output_schema do
            string :status, description: "The status"
            validates :status, exclusion: { in: %w[banned blocked] }
          end
        end

        it "includes exclusion validation in field description" do
          prompt = model.format_prompt(task)

          expected_description = <<~DESCRIPTION.chomp
            # status
            Description: The status
            Type: string
            Validations: must not be one of: banned, blocked
            Example: "your status here"
          DESCRIPTION

          expect(prompt).to include(expected_description)
        end
      end

      context "format validation" do
        before do
          task_class.output_schema do
            string :email, description: "Email address"
            validates :email, format: { with: /\A[^@\s]+@[^@\s]+\z/ }
          end
        end

        it "includes format validation in field description" do
          prompt = model.format_prompt(task)

          expected_description = <<~DESCRIPTION.chomp
            # email
            Description: Email address
            Type: string
            Validations: must match format: (?-mix:\\A[^@\\s]+@[^@\\s]+\\z)
            Example: "your email here"
          DESCRIPTION

          expect(prompt).to include(expected_description)
        end
      end

      context "length validation" do
        before do
          task_class.output_schema do
            string :password, description: "The password"
            validates :password, length: { minimum: 8, maximum: 20 }
          end
        end

        it "includes length validation in field description" do
          prompt = model.format_prompt(task)

          expected_description = <<~DESCRIPTION.chomp
            # password
            Description: The password
            Type: string
            Validations: must have at least 8 characters, must have at most 20 characters
            Example: "your password here"
          DESCRIPTION

          expect(prompt).to include(expected_description)
        end
      end

      context "numericality validation" do
        before do
          task_class.output_schema do
            integer :age, description: "The age"
            validates :age,
                      numericality: {
                        greater_than: 0,
                        less_than_or_equal_to: 120
                      }
          end
        end

        it "includes numericality validation in field description" do
          prompt = model.format_prompt(task)

          expected_description = <<~DESCRIPTION.chomp
            # age
            Description: The age
            Type: integer
            Validations: must be greater than 0, must be less than or equal to 120
            Example: 0
          DESCRIPTION

          expect(prompt).to include(expected_description)
        end
      end

      context "multiple validations" do
        before do
          task_class.output_schema do
            string :username, description: "The username"
            validates :username,
                      presence: true,
                      length: {
                        in: 3..20
                      },
                      format: {
                        with: /\A[a-z0-9_]+\z/
                      }
          end
        end

        it "includes all validations in field description" do
          prompt = model.format_prompt(task)

          expected_description = <<~DESCRIPTION.chomp
            # username
            Description: The username
            Type: string
            Validations: must be present, must have between 3 and 20 characters, must match format: (?-mix:\\A[a-z0-9_]+\\z)
            Example: "your username here"
          DESCRIPTION

          expect(prompt).to include(expected_description)
        end
      end

      context "array validations" do
        context "presence validation" do
          before do
            task_class.output_schema do
              array :tags, description: "List of tags" do
                string
              end
              validates :tags, presence: true
            end
          end

          it "includes presence validation in array description" do
            prompt = model.format_prompt(task)

            expected_description = <<~DESCRIPTION.chomp
              # tags
              Description: List of tags
              Type: array of strings
              Validations: must be present
              Example: ["first tag","second tag"]
            DESCRIPTION

            expect(prompt).to include(expected_description)
          end
        end

        context "length validation - minimum" do
          before do
            task_class.output_schema do
              array :categories, description: "List of categories" do
                string
              end
              validates :categories, length: { minimum: 2 }
            end
          end

          it "includes minimum length validation in array description" do
            prompt = model.format_prompt(task)

            expected_description = <<~DESCRIPTION.chomp
              # categories
              Description: List of categories
              Type: array of strings
              Validations: must have at least 2 elements
              Example: ["first category","second category"]
            DESCRIPTION

            expect(prompt).to include(expected_description)
          end
        end

        context "length validation - maximum" do
          before do
            task_class.output_schema do
              array :roles, description: "User roles" do
                string
              end
              validates :roles, length: { maximum: 5 }
            end
          end

          it "includes maximum length validation in array description" do
            prompt = model.format_prompt(task)

            expected_description = <<~DESCRIPTION.chomp
              # roles
              Description: User roles
              Type: array of strings
              Validations: must have at most 5 elements
              Example: ["first role","second role"]
            DESCRIPTION

            expect(prompt).to include(expected_description)
          end
        end

        context "length validation - range" do
          before do
            task_class.output_schema do
              array :features, description: "Product features" do
                string
              end
              validates :features, length: { in: 2..4 }
            end
          end

          it "includes range length validation in array description" do
            prompt = model.format_prompt(task)

            expected_description = <<~DESCRIPTION.chomp
              # features
              Description: Product features
              Type: array of strings
              Validations: must have between 2 and 4 elements
              Example: ["first feature","second feature"]
            DESCRIPTION

            expect(prompt).to include(expected_description)
          end
        end

        context "length validation - exact" do
          before do
            task_class.output_schema do
              array :coordinates, description: "Point coordinates" do
                float
              end
              validates :coordinates, length: { is: 3 }
            end
          end

          it "includes exact length validation in array description" do
            prompt = model.format_prompt(task)

            expected_description = <<~DESCRIPTION.chomp
              # coordinates
              Description: Point coordinates
              Type: array of floats
              Validations: must have exactly 3 elements
              Example: [1.0,2.0,3.0]
            DESCRIPTION

            expect(prompt).to include(expected_description)
          end
        end

        context "absence validation" do
          before do
            task_class.output_schema do
              array :deprecated_fields, description: "Deprecated fields" do
                string
              end
              validates :deprecated_fields, absence: true
            end
          end

          it "includes absence validation in array description" do
            prompt = model.format_prompt(task)

            expected_description = <<~DESCRIPTION.chomp
              # deprecated_fields
              Description: Deprecated fields
              Type: array of strings
              Validations: must be absent
              Example: ["first deprecated_field","second deprecated_field"]
            DESCRIPTION

            expect(prompt).to include(expected_description)
          end
        end
      end

      context "hash validations" do
        context "presence validation" do
          before do
            task_class.output_schema do
              hash :user_settings, description: "User configuration settings" do
                string :theme
                boolean :notifications_enabled
              end
              validates :user_settings, presence: true
            end
          end

          it "includes presence validation in hash field description" do
            prompt = model.format_prompt(task)

            expected_description = <<~DESCRIPTION.chomp
              # user_settings
              Description: User configuration settings
              Type: object
              Validations: must be present
              Example: {"theme":"your theme here","notifications_enabled":true}
            DESCRIPTION

            expect(prompt).to include(expected_description)
          end
        end
      end
    end

    context "with custom validation descriptions" do
      before do
        task_class.output_schema do
          string :name, description: "The person's name"
          integer :confidence, description: "Confidence score from 0-100"
          validate :validate_confidence_score, description: "Confidence score must be between 0 and 100"
          validate :validate_other_thing, description: nil
        end
      end

      it "includes an Additional Validations section with non-nil descriptions" do
        prompt = model.format_prompt(task)
        expect(prompt).to include("Additional Validations:")
        expect(prompt).to include("- Confidence score must be between 0 and 100")
        expect(prompt).not_to include("- \n") # Should not include a blank bullet for nil
      end

      it "omits Additional Validations section if all descriptions are nil" do
        # Redefine schema with only nil descriptions
        task_class.output_schema do
          string :name, description: "The person's name"
          validate :validate_confidence_score, description: nil
          validate :validate_other_thing, description: nil
        end
        prompt = model.format_prompt(task)
        expect(prompt).not_to include("Additional Validations:")
      end
    end

    context "JSON example generation" do
      context "with simple field types" do
        it "generates correct JSON example for string field" do
          task_class.output_schema do
            string :name, description: "The person's name"
          end

          prompt = model.format_prompt(task)

          expected_json = <<~JSON.chomp
          {
            "name": "your name here"
          }
        JSON

          expect(prompt).to include(expected_json)
        end

        it "generates correct JSON example for integer field" do
          task_class.output_schema do
            integer :age, description: "The person's age"
          end

          prompt = model.format_prompt(task)

          expected_json = <<~JSON.chomp
            {
              "age": 0
            }
          JSON

          expect(prompt).to include(expected_json)
        end

        it "generates correct JSON example for boolean field" do
          task_class.output_schema do
            boolean :is_active, description: "Whether the person is active"
          end

          prompt = model.format_prompt(task)

          expected_json = <<~JSON.chomp
            {
              "is_active": true
            }
          JSON

          expect(prompt).to include(expected_json)
        end

        it "generates correct JSON example for float field" do
          task_class.output_schema { float :score, description: "The score" }

          prompt = model.format_prompt(task)

          expected_json = <<~JSON.chomp
            {
              "score": 0.0
            }
          JSON

          expect(prompt).to include(expected_json)
        end

        it "generates correct JSON example for datetime field" do
          task_class.output_schema do
            datetime :created_at, description: "When it was created"
          end

          prompt = model.format_prompt(task)

          expected_json = <<~JSON.chomp
            {
              "created_at": "2024-01-01T12:00:00+00:00"
            }
          JSON

          expect(prompt).to include(expected_json)
        end
      end

      context "with array fields" do
        it "generates correct JSON example for array of strings" do
          task_class.output_schema do
            array :tags, description: "List of tags" do
              string
            end
          end

          prompt = model.format_prompt(task)

          expected_json = <<~JSON.chomp
            {
              "tags": [
                "first tag",
                "second tag"
              ]
            }
          JSON

          expect(prompt).to include(expected_json)
        end

        it "generates correct JSON example for array of integers" do
          task_class.output_schema do
            array :counts, description: "List of counts" do
              integer
            end
          end

          prompt = model.format_prompt(task)

          expected_json = <<~JSON.chomp
            {
              "counts": [
                1,
                2,
                3
              ]
            }
          JSON

          expect(prompt).to include(expected_json)
        end

        it "generates correct JSON example for array of datetimes" do
          task_class.output_schema do
            array :timestamps, description: "List of timestamps" do
              datetime
            end
          end

          prompt = model.format_prompt(task)

          expected_json = <<~JSON.chomp
            {
              "timestamps": [
                "2024-01-01T12:00:00+00:00",
                "2024-01-02T12:00:00+00:00"
              ]
            }
          JSON

          expect(prompt).to include(expected_json)
        end

        it "generates correct JSON example for array without element type" do
          task_class.output_schema do
            array :items, description: "List of items"
          end

          prompt = model.format_prompt(task)

          expected_json = <<~JSON.chomp
            {
              "items": []
            }
          JSON

          expect(prompt).to include(expected_json)
        end

        it "generates correct JSON example for nested array of strings" do
          task_class.output_schema do
            array :groups, description: "Groups of items" do
              array { string }
            end
          end

          prompt = model.format_prompt(task)

          expected_json = <<~JSON.chomp
            {
              "groups": [
                [
                  "first item",
                  "second item"
                ],
                [
                  "first item",
                  "second item"
                ]
              ]
            }
          JSON

          expect(prompt).to include(expected_json)
        end

        it "generates correct JSON example for three-dimensional array of integers" do
          task_class.output_schema do
            array :matrices, description: "Collection of matrices" do
              array { array { integer } }
            end
          end

          prompt = model.format_prompt(task)

          expected_json = <<~JSON.chomp
            {
              "matrices": [
                [
                  [
                    1,
                    2,
                    3
                  ],
                  [
                    1,
                    2,
                    3
                  ]
                ],
                [
                  [
                    1,
                    2,
                    3
                  ],
                  [
                    1,
                    2,
                    3
                  ]
                ]
              ]
            }
          JSON

          expect(prompt).to include(expected_json)
        end
      end

      context "with multiple fields" do
        it "generates correct JSON example for mixed field types" do
          task_class.output_schema do
            string :name, description: "The person's name"
            integer :age, description: "The person's age"
            array :hobbies, description: "List of hobbies" do
              string
            end
            datetime :joined_at, description: "When they joined"
          end

          prompt = model.format_prompt(task)

          expected_json = <<~JSON.chomp
              {
                "name": "your name here",
                "age": 0,
                "hobbies": [
                  "first hobby",
                  "second hobby"
                ],
                "joined_at": "2024-01-01T12:00:00+00:00"
              }
            JSON

          expect(prompt).to include(expected_json)
        end
      end

      context "with hash fields" do
        it "generates correct JSON example for simple hash" do
          task_class.output_schema do
            hash :config, description: "Configuration options" do
              string :host, description: "Server hostname"
              integer :port
            end
          end

          prompt = model.format_prompt(task)

          expected_json = <<~JSON.chomp
          {
            "config": {
              "host": "your host here",
              "port": 0
            }
          }
          JSON

          expect(prompt).to include(expected_json)
        end

        it "generates correct JSON example for nested hash" do
          task_class.output_schema do
            hash :user, description: "User profile" do
              string :name
              hash :address do
                string :street
                string :city
                string :country
              end
            end
          end

          prompt = model.format_prompt(task)

          expected_json = <<~JSON.chomp
          {
            "user": {
              "name": "your name here",
              "address": {
                "street": "your street here",
                "city": "your city here",
                "country": "your country here"
              }
            }
          }
          JSON

          expect(prompt).to include(expected_json)
        end

        it "generates correct JSON example for hash with array" do
          task_class.output_schema do
            hash :user_data, description: "User data" do
              string :username
              array :permissions do
                string
              end
            end
          end

          prompt = model.format_prompt(task)

          expected_json = <<~JSON.chomp
          {
            "user_data": {
              "username": "your username here",
              "permissions": [
                "first permission",
                "second permission"
              ]
            }
          }
          JSON

          expect(prompt).to include(expected_json)
        end
      end
    end
  end
end
