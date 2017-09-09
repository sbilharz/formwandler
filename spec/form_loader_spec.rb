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
  end

  context 'for actions without load_form' do
    subject { get :new }

    it 'does not assign @my_model_form' do
      subject
      expect(assigns(:my_model_form)).to be_nil
    end
  end
end
