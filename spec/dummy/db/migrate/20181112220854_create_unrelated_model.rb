class CreateUnrelatedModel < ActiveRecord::Migration[5.2]
  def change
    create_table :unrelated_models do |t|
      t.string :some_field

      t.timestamps
    end
  end
end
