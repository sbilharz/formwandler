# frozen_string_literal: true

module Formwandler
  class FieldValueTransformer
    attr_reader :in_transformation, :out_transformation

    def initialize(&block)
      instance_exec(&block)
    end

    def incoming(&block)
      @in_transformation = block
    end

    def outgoing(&block)
      @out_transformation = block
    end
  end
end
