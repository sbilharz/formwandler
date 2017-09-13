# frozen_string_literal: true

class MyModelForm < Formwandler::Form
  include ActionView::Helpers::NumberHelper

  field :field1, model: :my_model
  field :field2, model: :my_model
  field :field3
  field :field4, model: :my_model, source: :other_field
  field :transformed_field, model: :my_model do
    transform do
      incoming { |value| value.to_d / 100 }
      outgoing { |value| number_with_delimiter(value * 100) }
    end
  end
end
