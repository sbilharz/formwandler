class AddTransformedFieldToMyModels < ActiveRecord::Migration[5.1]
  def change
    add_column :my_models, :transformed_field, :decimal
  end
end
