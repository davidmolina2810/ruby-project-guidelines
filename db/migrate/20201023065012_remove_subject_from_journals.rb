class RemoveSubjectFromJournals < ActiveRecord::Migration[5.2]
  def change
    remove_column :journals, :subject
  end
end
