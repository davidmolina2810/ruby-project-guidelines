class Writer < ActiveRecord::Base
  has_many :entries
  has_many :journals, through: :entries

  def write_entry(journal, body, title = "Untitled") # create new entry in journal 
    Entry.create(body: body, title: title, writer_id: self.id, journal_id: journal.id)
  end

<<<<<<< HEAD
<<<<<<< HEAD
  def create_journal(name, subject = nil) # create journal belonging to self-writer
    j = Journal.create(name: name, subject: subject)
=======
  def create_journal(name, creator, subject = nil) # create journal belonging to self-writer
    j = Journal.create(name: name, creator: self.username, subject: subject)
>>>>>>> working
=======
  def create_journal(name, creator, subject = nil) # create journal belonging to self-writer
    j = Journal.create(name: name, creator: self.username, subject: subject)
>>>>>>> working
    #self.journals << j
    #default_entry = self.entries.find{|entry| entry.journal_id == j.id && entry.writer_id == self.id}
    #default_entry.update(title: "Default")
    #default_entry.update(body: "Default")
  end

  def update_entry(entry, journal, new_body = nil, new_title = nil) # update given entry in journal
    if new_body && new_title
      entry.update(body: new_body)
      entry.update(title: new_title)
    elsif new_body && !new_title
      entry.update(body: new_body)
    elsif !new_body && new_title
      entry.update(title: new_title)
    else 
      return "Must pass either new_body and/or new_title arguments"
    end
    journal.entries << entry
    self.entries << entry
    entry
  end

  def total_entries # returns total number of entries written by self-writer
    self.entries.length
  end
  
  def entry_by_title(title) # find an entry by title written by self-writer
    self.entries.find_by(title: title)
  end

  def delete_entry(entry) # delete given entry and return updated list of entries by self-writer
    entry.destroy
    self.entries
  end

  def delete_by_title(title) # delete entry by title and return updated list of entries by self-writer
    entry = Entry.find_by(title: title)
    delete_entry(entry)
  end
end 