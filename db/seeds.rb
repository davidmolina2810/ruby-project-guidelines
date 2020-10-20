Writer.destroy_all
Journal.destroy_all
Entry.destroy_all

writer1 = Writer.create(username: "David")
writer2 = Writer.create(username: "Wintana")
writer3 = Writer.create(username: "Steve")

j1 = Journal.create(name: "Journal 1")
j2 = Journal.create(name: "Journal 2")
j3 = Journal.create(name: "Journal 3")

writer1.write_entry(j1, "This is my first entry")
