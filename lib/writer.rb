class Writer < ActiveRecord::Base
  has_many :entries
  has_many :journals, through: :entries

  def write_entry(journal, body)
    entry = Entry.create(body: body)
    journal.entries << entry
    entries << entry
    entry
  end

  def update_entry(entry, new_body)
    entry.update(body: new_body)
  end
end 