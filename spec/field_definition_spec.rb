require 'spec_helper'

RSpec.describe Formwandler::FieldDefinition do
  let(:field_name) { :my_field }
  let(:options) { {} }
  let(:field_definition) { described_class.new(field_name, options) }

  subject { field_definition }

  describe '#hidden_options' do
    subject { super().hidden_options }

    context 'on a new instance' do
      it { is_expected.to eq({}) }
    end

    context 'when #hide_options has been called before' do
      before(:each) do
        field_definition.hide_option option_name, true
      end

      context 'with a symbol name parameter' do
        let(:option_name) { :my_option }

        it { is_expected.to eq({'my_option' => true}) }
      end

      context 'with a string name parameter' do
        let(:option_name) { 'my_option' }

        it { is_expected.to eq({'my_option' => true}) }
      end
    end
  end
end
