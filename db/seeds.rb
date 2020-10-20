Writer.destroy_all
Journal.destroy_all
Entry.destroy_all

writer1 = Writer.create(username: "David")
writer2 = Writer.create(username: "Wintana")
writer3 = Writer.create(username: "Steve")

writer1.create_journal("Journal 1")
writer2.create_journal("Journal 2")


#writer1.write_entry(j1, "This is my first entry", "Entry 1")
#writer2.write_entry(j1, "This is the second entry in this journal", "Entry2")
#writer1.write_entry(j1, "This is the third entry in this journal", "Entry3")
