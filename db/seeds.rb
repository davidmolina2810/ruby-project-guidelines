require 'pry'

Writer.destroy_all
Journal.destroy_all
Entry.destroy_all

david = Writer.create(username: "David", password: "dam")
#wintana = Writer.create(username: "Wintana", password: "xyz")
#writer3 = Writer.create(username: "Steve")

j1 = david.create_journal("Journal 1", "First journal")
j2 = david.create_journal('Journal 2', "Second Journal")

david.write_entry(j1, "This is the first entry in #{j1.name}", "Entry 1")
#wintana.write_entry(j2, "This is the first entry in #{j2.name}")
david.write_entry(j2, "This is the first entry in #{j2.name}", "Entry 1")
david.write_entry(j2, "This is the second entry in #{j2.name}", "Entry 2")

#e1 = Entry.create(title: "Entry1 ", writer_id: writer1.id, journal_id: j1.id, body: 'This is the first entry')
#e2 = Entry.create(title: "Entry 2", writer_id: writer2.id, journal_id: j2.id, body: 'This is the second entry')





#writer1.write_entry(j1, "This is my first entry", "Entry 1")
#writer2.write_entry(j1, "This is the second entry in this journal", "Entry2")
#writer1.write_entry(j1, "This is the third entry in this journal", "Entry3")
binding.pry
0