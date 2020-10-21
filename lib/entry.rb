class Entry < ActiveRecord::Base 
  belongs_to :writer
  belongs_to :journal

  def word_count # returns number of words in self-entry's body
    words = self.body.split(" ")
    words.length
  end

  def change_title(new_title)
    self.title = new_title
  end

end