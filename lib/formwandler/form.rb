# frozen_string_literal: true

require_relative 'field_definition'
require_relative 'field'
require 'delocalize'

module Formwandler
  class Form
    include ActiveModel::Model
    include ActiveModel::Validations::Callbacks

    class << self
      def model_name
        ActiveModel::Name.new(self, nil, name.chomp('Form').underscore)
      end

      def field_definitions
        @field_definitions ||= {}
      end

      def field(name, opts = {}, &block)
        field_definition = FieldDefinition.new(name, opts)
        field_definitions[name] = field_definition

        field_definition.instance_exec(&block) if block_given?

        attribute_accessor(name)
      end

      def attribute_accessor(name)
        define_method "#{name}=" do |value|
          field(name).value = value
        end

        define_method name do
          field(name).value
        end
      end

      def save_order(*model_names)
        @model_save_order = model_names
      end

      attr_reader :model_save_order
    end

    attr_reader :models, :controller

    def initialize(models: {}, controller:)
      @models = models.symbolize_keys
      @controller = controller

      initialize_fields
      initialize_models
      assign_defaults
      assign_params
    end

    def persisted?
      models.values.first&.persisted? || false
    end

    def to_param
      models.values.first.to_param
    end

    def field(name)
      @fields.fetch(name)
    end

    def fields(*names)
      if names.any?
        @fields.fetch_values(*names)
      else
        @fields.values
      end
    end

    def fields_for_model(model)
      fields.select { |field| field.model == model }
    end

    def models_valid?
      all_valid = true
      models.each do |name, model|
        all_valid = false if model.invalid?
        next if model.valid?
        fields_for_model(name).each do |field|
          model.errors[field.source].each do |error_message|
            errors.add(field.name, error_message)
          end
        end
      end
      all_valid
    end

    def submit
      if valid? && models_valid?
        ActiveRecord::Base.transaction do
          save_models!
        end
        load_results
      else
        false
      end
    end

    private

    def initialize_models
    end

    def assign_defaults
      fields.each do |field|
        next unless field.default?
        send("#{field.name}=", field.default) if send(field.name).nil?
      end
    end

    def assign_params
      return unless form_params?
      assign_attributes permitted_params
    end

    def save_models!
      models.sort_by do |(name, _model)|
        self.class.model_save_order&.index(name) || self.class.model_save_order&.size
      end.map(&:last).compact.each(&:save!)
    end

    def load_results
      true
    end

    def form_params?
      controller.params.fetch(model_name.param_key, {}).to_unsafe_h.any?
    end

    def permitted_params
      controller.params.require(model_name.param_key).permit(*visible_fields).delocalize(delocalizations)
    end

    def visible_fields
      fields.reject(&:hidden?).map do |field|
        field.array? ? {field.name => []} : field.name
      end
    end

    def delocalizations
      fields.reduce({}) do |memo, field|
        memo[field.name] = field.delocalize
        memo
      end.compact
    end

    def initialize_fields
      @fields = self.class.field_definitions.transform_values do |field_definition|
        Field.new(form: self, field_definition: field_definition)
      end
    end
  end
end
