# frozen_string_literal: true

module Formwandler
  class Field
    attr_reader :form, :field_definition

    delegate :name, :model, :source, to: :field_definition

    def initialize(form:, field_definition:)
      @form = form
      @field_definition = field_definition
    end

    def value=(new_value)
      new_value = transform_value(new_value, field_definition.in_transformation)
      if model_instance
        model_instance.public_send("#{source}=", new_value)
      else
        @value = new_value
      end
    end

    def value
      transform_value(raw_value, field_definition.out_transformation)
    end

    def raw_value
      model_instance ? model_instance.public_send(source) : @value
    end

    def hidden?
      _evaluate_field_definition_value(:hidden)
    end

    def visible?
      !hidden?
    end

    def disabled?
      _evaluate_field_definition_value(:disabled)
    end

    def readonly?
      _evaluate_field_definition_value(:readonly)
    end

    def options
      all_options - hidden_options
    end

    def default?
      !field_definition.default.nil?
    end

    def default
      _evaluate_field_definition_value(:default)
    end

    def delocalize
      _evaluate_field_definition_value(:delocalize)
    end

    def array?
      field_definition.array
    end

    private

    def transform_value(value, transformation)
      return value if !field_definition.transform_blank && (value.nil? || value == '')
      if transformation.respond_to?(:call)
        form.instance_exec(value, &transformation)
      else
        value
      end
    end

    def all_options
      _evaluate_field_definition_value(:options) || options_from_model || []
    end

    def hidden_options
      field_definition.hidden_options&.select do |_option, value|
        _evaluate_value(value)
      end&.keys || []
    end

    def options_from_model
      return unless model_instance.present? && model_instance.is_a?(ActiveRecord::Base)
      return unless enum_field?
      model_instance.class.public_send(name.to_s.pluralize).keys
    end

    def enum_field?
      model_instance.class.attribute_types[name.to_s].is_a?(ActiveRecord::Enum::EnumType)
    end

    def model_instance
      form.models[field_definition.model] if field_definition.model.present?
    end

    def _evaluate_field_definition_value(attr_name)
      value = field_definition.send(attr_name)
      _evaluate_value(value)
    end

    def _evaluate_value(value)
      if value.respond_to?(:call)
        form.instance_exec(&value)
      else
        value
      end
    end
  end
end
