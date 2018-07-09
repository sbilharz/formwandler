# frozen_string_literal: true

require_relative 'field_value_transformer'

module Formwandler
  class FieldDefinition
    attr_reader :name
    attr_accessor :hidden, :disabled, :default, :delocalize, :model, :source, :options, :array

    def initialize(name)
      @name = name
      set_defaults
    end

    def hide_option(name, value = true)
      hidden_options[name.to_s] = value
    end

    def hidden_options
      @hidden_options ||= {}
    end

    def transform(&block)
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
      @default = nil
      @delocalize = nil
      @model = nil
      @source = name
      @options = nil
      @array = false
    end
  end
end
