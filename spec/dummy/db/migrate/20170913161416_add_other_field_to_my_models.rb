class AddOtherFieldToMyModels < ActiveRecord::Migration[5.1]
  def change
    add_column :my_models, :other_field, :string
  end
end
