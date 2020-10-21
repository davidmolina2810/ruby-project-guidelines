class Entry < ActiveRecord::Base 
  belongs_to :writer
  belongs_to :journal


  def word_count
    body.scan(/(\w|-)+/).size
  end

end