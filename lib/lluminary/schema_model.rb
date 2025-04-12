require 'active_model'

module Lluminary
  class SchemaModel
    include ActiveModel::Validations

    attr_reader :attributes

    def initialize(attributes = {})
      @attributes = attributes.transform_keys(&:to_s)
    end

    def self.build(fields:, validations:)
      Class.new(self) do
        # Add accessors for each field
        fields.each_key do |name|
          define_method(name) { @attributes[name.to_s] }
          define_method("#{name}=") { |value| @attributes[name.to_s] = value }
        end

        # Add raw_response field and validation
        define_method(:raw_response) { @attributes['raw_response'] }
        define_method(:raw_response=) { |value| @attributes['raw_response'] = value }

        validate do |record|
          if record.raw_response
            begin
              JSON.parse(record.raw_response)
            rescue JSON::ParserError
              record.errors.add(:raw_response, "must be valid JSON")
            end
          end
        end

        # Add type validations
        validate do |record|
          record.attributes.each do |name, value|
            next if value.nil? || name == 'raw_response'

            field = fields[name.to_sym]
            next unless field

            case field[:type]
            when :string
              unless value.is_a?(String)
                record.errors.add(name, "must be a String")
              end
            when :integer
              unless value.is_a?(Integer)
                record.errors.add(name, "must be an Integer")
              end
            end
          end
        end

        # Add ActiveModel validations
        validations.each do |args, options|
          validates(*args, **options)
        end

        # Set model name for error messages
        define_singleton_method(:model_name) do
          ActiveModel::Name.new(self, nil, "SchemaModel")
        end
      end
    end
  end
end 