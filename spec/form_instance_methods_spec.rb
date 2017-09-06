require 'spec_helper'

RSpec.describe Formwandler::Form do
  let(:form_class) do
    Class.new(described_class) do
      class << self
        def name
          'MyModelForm'
        end
      end
    end
  end
  let(:my_model) { double }
  let(:form) { form_class.new(models: {my_model: my_model}) }

  describe '#field' do
    subject { form.field(field_name) }

    context 'with no argument' do
      subject { form.field }

      it_behaves_like 'raising an ArgumentError'
    end

    context 'with a non-existent field name' do
      let(:field_name) { :foo }

      it_behaves_like 'raising a KeyError'
    end

    context 'with the name of a defined field' do
      let(:field_name) { :my_field }

      before(:each) do
        form_class.class_eval do
          field :my_field
        end
      end

      it { is_expected.to be_an_instance_of(Formwandler::Field) }
    end
  end
end
