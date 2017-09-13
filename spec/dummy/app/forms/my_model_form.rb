# frozen_string_literal: true

class MyModelForm < Formwandler::Form
  field :field1, model: :my_model
  field :field2, model: :my_model
  field :field3
  field :transformed_field, model: :my_model do
    transform do
      incoming { |value| value.to_d / 100 }
      outgoing { |value| value * 100 }
    end
  end
end
