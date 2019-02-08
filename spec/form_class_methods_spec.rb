require 'spec_helper'

RSpec.describe Formwandler::Form do
  class MyForm < described_class
  end

  describe '.field' do
    let(:name) { 'the_field' }
    let(:options) { {hidden: true, model: :my_model} }
    let(:block) do
      lambda do
        hide_option :my_option, -> { true }
      end
    end

    shared_examples_for 'initializing #model_class' do
      subject do
        super()
        MyForm.field_definitions[name].model_class
      end

      shared_examples_for 'prioritizing :model_class' do
        let(:options) { super().merge(model_class: UnrelatedModel) }

        it { is_expected.to be(UnrelatedModel) }
      end

      context 'when the model class is inferrable from :model' do
        it { is_expected.to be(MyModel) }
        it_behaves_like 'prioritizing :model_class'
      end

      context 'when the model class is not inferrable from :model 1' do
        let(:options) { super().merge(model: :not_inferrable_model) }

        it { is_expected.to be_nil }
        it_behaves_like 'prioritizing :model_class'
      end

      context 'when the model class is not inferrable from :model 2' do
        let(:options) { super().merge(model: nil) }

        it { is_expected.to be_nil }
        it_behaves_like 'prioritizing :model_class'
      end
    end

    context 'with no arguments' do
      subject { MyForm.field }

      it_behaves_like 'raising an ArgumentError'
    end

    context 'with a name but no options and no block' do
      subject { MyForm.field(name) }

      it_behaves_like 'not raising an error'
    end

    context 'with a name and options but no block' do
      subject { MyForm.field(name, options) }

      it_behaves_like 'not raising an error'
      it_behaves_like 'initializing #model_class'

      context 'with invalid options' do
        let(:options) { {foo: 'bar'} }

        it_behaves_like 'raising an ArgumentError'
      end
    end

    context 'with a name and options and a block' do
      subject { MyForm.field(name, options, &block) }

      it_behaves_like 'not raising an error'
      it_behaves_like 'initializing #model_class'

      context 'when the field was already defined' do
        let(:default_value) { 'a_string' }
        let(:form_instance) { MyForm.new(models: {}, controller: double(params: ActionController::Parameters.new({}))) }

        before(:each) do
          MyForm.field name, model: :another_model, default: default_value
        end

        it 'overwrites the given options' do
          subject
          expect(form_instance.field(name).model).to eq(options[:model])
        end

        it 'keeps options that haven\'t been overwritten' do
          subject
          expect(form_instance.field(name).default).to eq(default_value)
        end
      end
    end
  end

  describe '.human_attribute_name' do
    subject { MyModelForm.human_attribute_name(field, options) }

    let(:options) { {} }

    describe 'for a field with translation in form namespace' do
      context 'when the field is backed by a model' do
        let(:field) { :field1 }

        it { is_expected.to eq('Field1 directly') }
      end

      context 'when the field is not backed by a model' do
        let(:field) { :field3 }

        it { is_expected.to eq('Field3 directly') }
      end
    end

    describe 'for a field with translation in the backing model\s namespace' do
      shared_examples_for 'prioritizing an explicit default' do
        let(:options) { super().merge(default: 'I have precedence') }

        it { is_expected.to eq('I have precedence') }
      end

      context 'when the field has no different source' do
        let(:field) { :field2 }

        it { is_expected.to eq('Field2 by model') }
        it_behaves_like 'prioritizing an explicit default'
      end

      context 'when the field has a different source' do
        let(:field) { :field4 }

        it { is_expected.to eq('Field4 by model') }
        it_behaves_like 'prioritizing an explicit default'
      end
    end
  end
end
