# frozen_string_literal: true

module Formwandler
  class FieldDefinition
    attr_reader :name, :hidden, :disabled, :default, :delocalize, :model, :source, :options

    def initialize(name, hidden: false, disabled: false, default: nil, delocalize: nil, model: nil, source: nil, options: nil)
      @name = name
      @hidden = hidden
      @disabled = disabled
      @default = default
      @delocalize = delocalize
      @model = model
      @source = source || name
      @options = options
    end

    def hide_option(name, value = true)
      hidden_options[name.to_s] = value
    end

    def hidden_options
      @hidden_options ||= {}
    end
  end
end
