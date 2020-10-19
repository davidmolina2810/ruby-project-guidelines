class Entry < ActiveRecord::Base 
  belongs_to :writer
  belongs_to :journal
end