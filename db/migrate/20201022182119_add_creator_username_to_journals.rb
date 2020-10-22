class AddCreatorUsernameToJournals < ActiveRecord::Migration[5.2]
  def change
    add_column :journals, :creator, :string
  end
end
