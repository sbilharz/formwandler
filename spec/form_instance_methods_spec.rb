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
  let(:my_model) { double('ActiveRecord::Base', valid?: true, invalid?: false, save!: true) }
  let(:models) { {my_model: my_model} }
  let(:form) { form_class.new(models: models) }

  before(:each) do
    form_class.class_eval do
      field :field1, model: :my_model
      field :field2, model: :my_model
      field :field3
    end
  end

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

  describe '#fields' do
    context 'with no arguments' do
      subject { form.fields }

      it { is_expected.to match_array([an_instance_of(Formwandler::Field)] * 3) }
      it { is_expected.to match_array([have_attributes(name: :field1), have_attributes(name: :field2), have_attributes(name: :field3)]) }
    end

    context 'with multiple existing field names as arguments' do
      subject { form.fields(:field1, :field3) }

      it { is_expected.to match_array([an_instance_of(Formwandler::Field)] * 2) }
      it { is_expected.to match_array([have_attributes(name: :field1), have_attributes(name: :field3)]) }
    end

    context 'with a list of field names that contains a non-existent field' do
      subject { form.fields(:field2, :foo) }

      it_behaves_like 'raising a KeyError'
    end
  end

  describe '#submit' do
    let(:my_model_params) { {field1: 'value1', field2: 'value2', field3: 'value3'} }
    let(:params) { {my_model: my_model_params} }

    subject { form.submit(params) }

    before(:each) do
      expect(my_model).to receive(:field1=).with('value1').and_return('value1')
      expect(my_model).to receive(:field2=).with('value2').and_return('value2')
    end

    context 'when all models are valid' do
      it { is_expected.to eq(true) }
    end
  end
end
