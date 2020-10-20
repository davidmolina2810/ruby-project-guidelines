require 'pry'

Writer.destroy_all
Journal.destroy_all
Entry.destroy_all

writer1 = Writer.create(username: "David", password: "abc")
writer2 = Writer.create(username: "Wintana", password: "xyz")
#writer3 = Writer.create(username: "Steve")

j1 = Journal.create(name: "Journal 1", subject: "First Journal")
j2 = Journal.create(name: "Journal 2", subject: "Second Journal")

e1 = Entry.create(title: "Entry1 ", writer_id: writer1.id, journal_id: j1.id, body: 'This is the first entry')
e2 = Entry.create(title: "Entry 2", writer_id: writer2.id, journal_id: j2.id, body: 'This is the second entry')


#writer1.write_entry(j1, "This is my first entry", "Entry 1")
#writer2.write_entry(j1, "This is the second entry in this journal", "Entry2")
#writer1.write_entry(j1, "This is the third entry in this journal", "Entry3")
binding.pry
0