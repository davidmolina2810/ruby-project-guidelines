class AddBodyColumnToEntries < ActiveRecord::Migration[5.2]
  def change
    add_column :entries, :body, :string
  end
end
