class Entry < ActiveRecord::Base 
  belongs_to :writer
  belongs_to :journal
end

def word_count
  body.scan(/(\w|-)+/).size
end