# frozen_string_literal: true

class DuplicateValidationForm < Formwandler::Form
  field :field2, model: :my_model

  validates :field2, inclusion: {in: ['value2']}
end
