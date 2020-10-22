class Entry < ActiveRecord::Base 
  belongs_to :writer
  belongs_to :journal


  def word_count
    body.scan(/(\w|-)+/).size
  end

  def change_title(new_title)
    self.title = new_title
  end

end