# frozen_string_literal: true

module Formwandler
  class Field
    attr_reader :form, :field_definition

    delegate :name, :model, :source, to: :field_definition

    def initialize(form:, field_definition:)
      @form = form
      @field_definition = field_definition
    end

    def hidden?
      if field_definition.hidden.respond_to?(:call)
        form.instance_exec(&field_definition.hidden)
      else
        field_definition.hidden
      end
    end

    def visible?
      !hidden?
    end

    def disabled?
      if field_definition.disabled.respond_to?(:call)
        form.instance_exec(&field_definition.disabled)
      else
        field_definition.disabled
      end
    end

    def options
      all_options - hidden_options
    end

    def default?
      !field_definition.default.nil?
    end

    def default
      if field_definition.default.respond_to?(:call)
        form.instance_exec(&field_definition.default)
      else
        field_definition.default
      end
    end

    def delocalize
      if field_definition.delocalize.respond_to?(:call)
        form.instance_exec(&field_definition.delocalize)
      else
        field_definition.delocalize
      end
    end

    private

    def all_options
      _evaluate_field_definition_value(:options) || options_from_model || []
    end

    def hidden_options
      field_definition.hidden_options&.reject do |_option, value|
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
      form.models[field_definition.model]
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
