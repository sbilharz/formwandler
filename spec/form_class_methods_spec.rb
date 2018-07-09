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

      context 'with invalid options' do
        let(:options) { {foo: 'bar'} }

        it_behaves_like 'raising an ArgumentError'
      end
    end

    context 'with a name and options and a block' do
      subject { MyForm.field(name, options, &block) }

      it_behaves_like 'not raising an error'

      context 'when the field was already defined' do
        before(:each) do
          MyForm.field name, model: :another_model
        end

        it 'overwrites the given options' do
          subject
          expect(MyForm.new(models: {}, controller: double(params: ActionController::Parameters.new({}))).field(name).model).to eq(options[:model])
        end
      end
    end
  end
end
