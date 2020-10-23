class Journal < ActiveRecord::Base
  has_many :entries
  has_many :writers, through: :entries

  def num_entries # returns num of entries in self-journal
    self.entries.length
  end

  def last_entry # returns last entry in self-journal
    self.entries.last
  end

  def entry_by_title(title) # find an entry by title in self-journal
    self.entries.find_by(title: title)
  end

  def entries_by_writer(writer) # find all entries in self-journal by given writer
    self.entries.select{ |entry| entry.writer == writer }
  end

end
