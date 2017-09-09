class CreateMyModels < ActiveRecord::Migration[5.1]
  def change
    create_table :my_models do |t|
      t.string :field1
      t.string :field2

      t.timestamps
    end
  end
end
