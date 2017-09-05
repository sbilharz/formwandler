# frozen_string_literal: true

require_relative 'field_definition'
require_relative 'field'

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

      def field(name, opts = {})
        field_definitions[name] = FieldDefinition.new(name, opts)

        yield(field_definitions[name]) if block_given?

        if field_definitions[name].model.present?
          attribute_accessor(name, field_definitions[name])
        else
          attr_accessor name
        end
      end

      def attribute_accessor(name, field_definition)
        define_method "#{name}=" do |value|
          models[field_definition.model].send("#{field_definition.source}=", value)
        end

        define_method name do
          models[field_definition.model].send(field_definition.source)
        end
      end

      def save_order(*model_names)
        @model_save_order = model_names
      end

      attr_reader :model_save_order
    end

    attr_reader :fields, :models, :current_user

    def initialize(models: {}, current_user: nil)
      @models = models.symbolize_keys
      @current_user = current_user

      initialize_fields
      initialize_models
      assign_defaults
    end

    def persisted?
      models.values.first&.persisted? || false
    end

    def to_param
      models.values.first.to_param
    end

    def field(name)
      fields.fetch(name)
    end

    def fields_for_model(model)
      fields.values.select { |field| field.model == model }
    end

    def models_valid?
      all_valid = true
      models.each do |name, model|
        all_valid = false if model.invalid?
        fields_for_model(name).each do |field|
          model.errors[field.source].each do |error_message|
            errors.add(field.name, error_message)
          end
        end
      end
      all_valid
    end

    def submit(params)
      assign_attributes permitted_params(params)

      if valid? && models_valid?
        save_models!
        load_results
      else
        false
      end
    end

    protected

    def initialize_models
    end

    def assign_defaults
      fields.values.each do |field|
        next unless field.default?
        send("#{field.name}=", field.default) if send(field.name).nil?
      end
    end

    def save_models!
      models.sort_by do |(name, _model)|
        self.class.model_save_order.index(name) || self.class.model_save_order.size
      end.map(&:last).compact.each(&:save!)
    end

    def load_results
      true
    end

    def permitted_params(params)
      visible_fields = fields.values.reject(&:hidden?).map(&:name)
      delocalizations = fields.transform_values(&:delocalize).compact
      params = ActionController::Parameters.new(params) if params.is_a?(Hash)
      params.require(model_name.param_key).permit(*visible_fields).delocalize(delocalizations)
    end

    private

    def initialize_fields
      @fields = self.class.field_definitions.transform_values do |field_definition|
        Field.new(form: self, field_definition: field_definition)
      end
    end
  end
end
