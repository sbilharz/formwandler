# frozen_string_literal: true

module MyNamespace
  class MyModelForm < Formwandler::Form
    field :field1, model: :my_model
    field :field2, model: :my_model
  end
end
