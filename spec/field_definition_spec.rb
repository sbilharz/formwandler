require 'spec_helper'

RSpec.describe Formwandler::FieldDefinition do
  let(:field_name) { :my_field }
  let(:field_definition) { described_class.new(field_name) }

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

  describe '#model=' do
    subject(:assign_model) { field_definition.model = new_model }

    shared_examples_for 'changing #model' do |from:, to:|
      it "from #{from} to #{to}" do
        expect { subject }.to change { field_definition.model }.from(from).to(to)
      end
    end

    context 'when the model class is inferrable' do
      let(:new_model) { :my_model }

      it_behaves_like 'changing #model', from: nil, to: :my_model

      it 'sets the inferred model class' do
        expect { subject }.to change { field_definition.model_class }.from(nil).to(MyModel)
      end
    end

    context 'when the model class is not inferrable' do
      let(:new_model) { :not_inferrable }

      context 'when @model_class=nil' do
        it_behaves_like 'changing #model', from: nil, to: :not_inferrable

        it 'does not change the model class' do
          expect { subject }.not_to change { field_definition.model_class }.from(nil)
        end
      end

      context 'when @model_class=UnrelatedModel' do
        before { field_definition.model_class = UnrelatedModel }

        it_behaves_like 'changing #model', from: nil, to: :not_inferrable

        it 'does not change the model class' do
          expect { subject }.to change { field_definition.model_class }.from(UnrelatedModel).to(nil)
        end
      end
    end
  end
end
