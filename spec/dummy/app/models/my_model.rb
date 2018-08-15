# frozen_string_literal: true

class MyModel < ApplicationRecord
  validates :field2, inclusion: {in: ['value2']}
end
