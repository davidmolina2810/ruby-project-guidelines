Writer.destroy_all
Journal.destroy_all
Entry.destroy_all

writer1 = Writer.create(username: "David")
writer2 = Writer.create(username: "Wintana")
writer3 = Writer.create(username: "Steve")

j1 = Journal.create(name: "Journal 1")
j2 = Journal.create(name: "Journal 2")
j3 = Journal.create(name: "Journal 3")

e1 = Entry.create
e2 = Entry.create
e3 = Entry.create

writer1.entries << e1
j1.entries << e1