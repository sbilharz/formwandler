require 'byebug'

ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require 'rspec/rails'
require 'rails-controller-testing'
Rails::Controller::Testing.install

RSpec.configure do |c|
  c.infer_base_class_for_anonymous_controllers = false
end

RSpec.shared_examples_for 'raising an ArgumentError' do
  it 'raises an ArgumentError' do
    expect { subject }.to raise_error(ArgumentError)
  end
end

RSpec.shared_examples_for 'raising a KeyError' do
  it 'raises a KeyError' do
    expect { subject }.to raise_error(KeyError)
  end
end

RSpec.shared_examples_for 'not raising an error' do
  it 'does not raise an error' do
    expect { subject }.to_not raise_error
  end
end
