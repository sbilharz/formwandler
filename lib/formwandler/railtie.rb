# frozen_string_literal: true

require_relative 'form_loader'

module Formwandler
  class Railtie < Rails::Railtie
    initializer 'formwandler.form_loader' do
      ActionController::Base.send(:include, Formwandler::FormLoader)
    end
  end
end
