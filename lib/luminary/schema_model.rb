require 'active_model'

module Luminary
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

        # Add type validations
        validate do |record|
          record.attributes.each do |name, value|
            next if value.nil?

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