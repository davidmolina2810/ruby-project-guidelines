class AddJournalAndWriterIdColumns < ActiveRecord::Migration[5.2]
  def change
    add_column :entries, :journal_id, :integer
    add_column :entries, :writer_id, :integer
  end
end
