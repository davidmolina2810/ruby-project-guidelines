class Writer < ActiveRecord::Base
  has_many :entries
  has_many :journals, through: :entries

  def write_entry(journal, body) # create new entry in journal 
    entry = Entry.create(body: body)
    journal.entries << entry
    entries << entry
    entry
  end
  
  def entry_by_title(title)
    Entry.find_by(title: title)
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

  def delete_entry(entry)
    entry.destroy
    self.entries
  end
end 