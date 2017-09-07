require 'active_support/core_ext/hash'
require 'active_record'
require 'active_model'
require 'action_controller'
require 'delocalize'
require 'formwandler'

# manually plug in the delocalize gem since we don't have a properly intiated rails app
ActionController::Parameters.send(:include, Delocalize::ParameterDelocalizing)

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
