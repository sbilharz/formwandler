# frozen_string_literal: true

class MyModelForm < Formwandler::Form
  field :field1, model: :my_model
  field :field2, model: :my_model
  field :field3
end
