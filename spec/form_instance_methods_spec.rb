require 'spec_helper'

RSpec.describe Formwandler::Form do
  let(:form_class) { MyModelForm }
  let(:my_model) { MyModel.new }
  let(:models) { {my_model: my_model} }
  let(:controller) { double('MyModelsController', params: ActionController::Parameters.new(params)) }
  let(:params) { {} }
  let(:form) { form_class.new(models: models, controller: controller) }

  describe '#initialize' do
    let(:my_model_params) { {field1: 'value1', field2: 'value2', field3: 'value3'} }
    let(:params) { super().merge(my_model: my_model_params) }

    subject { form }

    it 'assigns the matching params' do
      expect(my_model).to receive(:field1=).with('value1').and_return('value1')
      expect(my_model).to receive(:field2=).with('value2').and_return('value2')
      subject
    end

    context 'when a field has a "source" option specified' do
      let(:my_model_params) { super().merge(field4: 'value4') }

      it 'correctly assigns the value' do
        expect(my_model).to receive(:other_field=).with('value4').and_return('value4')
        subject
      end
    end

    context 'when a field has an "in" transformation' do
      let(:my_model_params) { super().merge(transformed_field: '5') }

      it 'applies the transformation before assigning the value to the model' do
        expect(my_model).to receive(:transformed_field=).with(0.05).and_return(0.05)
        subject
      end
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
      let(:field_name) { :field1 }

      it { is_expected.to be_an_instance_of(Formwandler::Field) }
    end
  end

  describe '#fields' do
    context 'with no arguments' do
      subject { form.fields }

      it { is_expected.to match_array([an_instance_of(Formwandler::Field)] * 5) }
      it { is_expected.to match_array([have_attributes(name: :field1), have_attributes(name: :field2), have_attributes(name: :field3), have_attributes(name: :transformed_field), have_attributes(name: :field4)]) }
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
    subject { form.submit }

    context 'when all models are valid' do
      it { is_expected.to eq(true) }
    end
  end
end
