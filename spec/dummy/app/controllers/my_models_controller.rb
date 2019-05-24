# frozen_string_literal: true

class MyModelsController < ApplicationController
  load_form only: [:index]

  def index
    head 200
  end

  def new
    head 200
  end

  def create
    head 201
  end
end
