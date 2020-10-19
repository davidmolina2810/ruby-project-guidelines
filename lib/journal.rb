class Journal < ActiveRecord::Base
  has_many :entries
  has_many :writers, through: :entries

  def num_entries # returns num of entries in self-journal
    self.entries.length
  end

  def last_entry # returns last entry in self-journal
    self.entries.last
  end

  

end
