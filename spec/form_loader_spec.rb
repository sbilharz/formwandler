require 'spec_helper'

RSpec.describe Formwandler::FormLoader, type: :controller do
  controller MyModelsController do
    load_form only: [:index]

    def index
      head 200
    end

    def new
      head 200
    end
  end

  context 'for actions with load_form' do
    subject { get :index }

    it 'assigns @my_model_form' do
      subject
      expect(assigns(:my_model_form)).to be_an_instance_of(MyModelForm)
    end

    context 'when a model instance is assigned to the matching instance variable' do
      controller MyModelsController do
        before_action { @my_model = MyModel.new }

        load_form only: [:index]

        def index
          head 200
        end
      end

      it 'injects it to the form instance' do
        subject
        expect(assigns(:my_model_form).models[:my_model]).to be_an_instance_of(MyModel)
      end
    end

    context 'when the matching instance variable is not assigned' do
      it 'does not inject nil into the form instance' do
        subject
        expect(assigns(:my_model_form).models.values).to_not include(nil)
      end
    end

    context 'when the controller lives within a namespace' do
      class MyNamespace::MyModelsController < ApplicationController; end

      controller MyNamespace::MyModelsController do
        load_form

        def index
          head 200
        end
      end

      it 'creates a form from the namespace' do
        subject
        expect(assigns(:my_model_form)).to be_an_instance_of(MyNamespace::MyModelForm)
      end
    end
  end

  context 'for actions without load_form' do
    subject { get :new }

    it 'does not assign @my_model_form' do
      subject
      expect(assigns(:my_model_form)).to be_nil
    end
  end
end
