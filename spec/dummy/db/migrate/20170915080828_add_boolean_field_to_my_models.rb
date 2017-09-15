class AddBooleanFieldToMyModels < ActiveRecord::Migration[5.1]
  def change
    add_column :my_models, :boolean_field, :boolean
  end
end
