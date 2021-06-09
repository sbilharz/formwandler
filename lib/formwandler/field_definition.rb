# frozen_string_literal: true

require_relative 'field_value_transformer'

module Formwandler
  class FieldDefinition
    attr_reader :name, :transform_blank
    attr_accessor :hidden, :disabled, :readonly, :default, :delocalize, :model, :model_class, :source, :options, :array

    def initialize(name)
      @name = name
      @transform_blank = false
      set_defaults
    end

    def model=(model)
      set_model model, model
    end

    def model_class=(symbol_or_class)
      @model_class =
        if symbol_or_class.nil?
          nil
        elsif symbol_or_class.is_a?(Symbol)
          symbol_or_class.to_s.classify.constantize rescue nil
        elsif symbol_or_class < ActiveRecord::Base || symbol_or_class < ActiveModel::Model
          symbol_or_class
        else
          fail 'The model class must be nil, a symbol or a descendant of ActiveModel::Model or ActiveRecord::Base.'
        end
    end

    def configure(opts)
      model = opts[:model]
      model_class = opts[:model_class] || model
      set_model model, model_class
      opts.except(:model, :model_class).each do |key, value|
        send("#{key}=", value)
      rescue NoMethodError
        raise ArgumentError, "Invalid option #{key}"
      end
    end

    def hide_option(name, value = true)
      hidden_options[name.to_s] = value
    end

    def hidden_options
      @hidden_options ||= {}
    end

    def transform(allow_blank: false, &block)
      @transform_blank = allow_blank
      @value_transformer = FieldValueTransformer.new(&block)
    end

    def in_transformation
      value_transformer&.in_transformation
    end

    def out_transformation
      value_transformer&.out_transformation
    end

    private

    attr_reader :value_transformer

    def set_defaults
      @hidden = false
      @disabled = false
      @readonly = false
      @default = nil
      @delocalize = nil
      @model = nil
      @model_class = nil
      @source = name
      @options = nil
      @array = false
    end

    def set_model(model, model_class)
      @model = model
      self.model_class = model_class
    end
  end
end
