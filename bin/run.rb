require_relative '../config/environment'

def get_user # if username not associated with a Writer, return false, else return the Writer instance
  print "Enter your username: "
  username = gets.chomp
  print "Enter your password: "
  password = gets.chomp
  if get_writer_by_user_and_pass(username, password) == nil
    print "Hmm... I can't find you. Are you a new writer? (Y/N) "
    choice = gets.chomp.upcase
    if choice == 'Y'
      return create_writer
    elsif choice == 'N'
      get_user
    end
  else
    return get_writer_by_user_and_pass(username, password)
  end
end

def welcome(user)
  pastel = Pastel.new
  puts pastel.decorate("Welcome to your Journal Explorer, #{user.username}!", :green, :bold)
end

def first_menu 
  choice = prompt_menu_input(home_menu_box) # 1. Create Journal, 2. View your Journals, 3. Exit
  puts
  puts
  
  if choice == 1 # create a new journal and associates to $user by creating first entry

    create_and_associate_journal


  elsif choice == 2 # view all journals by this user
    this_users_journals = show_journals
    choice = prompt_menu_input(view_journals_menu_box) # 1. Open a journal, 2. edit a journal, 3. Delete a journal

    if choice == 1 # open a journal
      journal = select_journal(this_users_journals)
      entries_in_this_journal = show_entries(journal)
      user_choice = prompt_menu_input(entry_edit_menu_box)
      
      if user_choice == 1 # write an entry
        write_entry(journal)
      elsif user_choice == 2 # view an entry 
        entry = select_entry(entries_in_this_journal)
        entry_title_box(entry)
        entry_body_box(entry)
      elsif user_choice == 3  # edit an entry
        
      elsif user_choice == 4 # delete an entry

      end


    elsif choice == 2 # edit a journal
      journal = select_journal(journal_names)
      ans = prompt_menu_input(journal_edit_menu_box, "What do you want to change about #{journal.name}?")

      if ans == 1 # change name of journal
        update_journal_name(journal)

      elsif ans == 2 # change subject of journal
        update_journal_subject(journal)

      elsif ans == 3 # change both subject and name 
        update_journal_name(journal)
        update_journal_subject(journal)
      end
      
    elsif choice == 3 # delete a journal
      journal = select_journal(journal_names)
      delete_journal(journal)
    end
  
  elsif choice == 3
    return
  end
end

def new_page
  for x in 1..15
    puts
  end
end

def create_and_associate_journal
  journal = create_journal
  divider
  if !$user.journals.include?(journal) # if new journal has not been associated with $user bc no entry has been made
    puts "Let's make your first entry in #{journal.name}!"
    write_entry(journal)
  end
  divider
end

def prompt_menu_input(box, prompt = "What do you want to do?") # prompts user, prints box menu, returns choice as Int
  puts prompt
  box
  print "--> "
  choice = gets.chomp.to_i
end

def write_entry(journal)
  print "Can you think of a title for you entry? (Y/N) "
  resp = gets.chomp.upcase
  if resp == "Y"
    write_entry_with_title(journal)
  elsif resp == "N"
    write_entry_without_title(journal)
  end
end

def create_writer
  puts "You are making a new account."
  print "Enter a username: "
  username = gets.chomp
  print "Enter a password: "
  pass = gets.chomp
  Writer.create(username: username, password: pass)
end

def get_writer_by_user_and_pass(username, password) # return Writer that matches username and password
  Writer.find_by(username: username, password: password)
end

def divider
  puts "==========================="
end

def single_divider
  puts "---------------------------"
end

def home_menu_box 
  box = TTY::Box.frame "1. Create new Journal", "2. View Your Journals", "3. Exit", align: :left
  print box 
  single_divider
end

def view_journals_menu_box
  box = TTY::Box.frame "1. Open a journal", "2. Edit a journal", "3. Delete a journal", align: :left
  print box
  single_divider
end

def journal_edit_menu_box
  box = TTY::Box.frame "1. Change journal name", "2. Change journal subject", "3. Both", align: :left
  print box
  single_divider
end

def entry_edit_menu_box
  box = TTY::Box.frame "1. Write an entry", "2. View an entry", "3. Edit an entry", "4. Delete an entry", align: :left
  print box
end

def show_journals # show all journals' names by $user and return journals
  puts "Here are your journals: "
  divider
  journals = $user.journals.uniq
  if !journals.empty?
    puts "No.       Title"
    puts "---       -----"
    for x in (1..journals.length) do 
      puts "#{x}.       #{journals[x-1].name}"
    end
  end
  journals
end

def select_journal(journals) # get one journal instance
  print "Select a journal number: "
  num = gets.chomp.to_i
  single_divider
  journal = journals[num-1]
  puts "Opening #{journal.name}..."
  divider
  journal 
end

def select_entry(entries) # get one entry instance
  print "Select an entry number: "
  num = gets.chomp.to_i
  single_divider
  entry = entries[num-1]
  puts "Opening #{entry.title}..."
  divider
  entry
end


def show_entries(journal) # show all entries by $user in journal and return entries
  puts "Here are the entries in this journal:"
  divider
  entries = journal.entries
  if !entries.empty?
    puts "No.      Title"
    puts "---      -----"
    for x in (1..entries.length) do 
      puts "#{x}.      #{entries[x-1].title}"
    end
  end
  entries
end

def create_journal
  puts "What do you want to call this journal?"
  print "--> "
  journal_name = gets.chomp
  puts "Do you want to add a subject? (Y/N) "
  print "--> "
  choice = gets.chomp.upcase
  if choice == "Y"
    puts "What subject should this journal be?"
    print "--> "
    subject = gets.chomp.capitalize
    journal = $user.create_journal(journal_name, subject)
    single_divider
    puts "New journal, '#{journal_name}', of subject, '#{subject}', created."
    journal
  else
    journal = $user.create_journal(journal_name)
    single_divider
    puts "New journal, '#{journal_name}', created."
    journal
  end 
end

def delete_journal(journal) # delete given journal from db
  puts "Destroyed journal, #{journal.name}."
  entries = Entry.all.select{ |entry| entry.journal_id == journal.id }
  entries.each { |entry| entry.destroy }
  journal.destroy
end

def write_entry_with_title(journal)
  puts
  print "Awesome! Enter your entry's title here: "
  title = gets.chomp.titleize
  puts "Type your entry below. Hitting enter will end your current writing session and save your entry."
  puts
  body = gets.chomp
  $user.write_entry(journal, body, title)
end

def write_entry_without_title(journal)
  puts
  puts "No worries! Many writers don't put a title on their books until they've written the last page!"
  puts
  puts "Let's get started on your entry."
  single_divider
  puts "Type your entry below. Hitting enter will end your current writing session and save your entry."
  puts
  body = gets.chomp
  $user.write_entry(journal, body)
end

def update_journal_name(journal)
  puts "What do you want the new name to be?"
  print "--> "
  new_name = gets.chomp.titleize
  journal.update(name: new_name)
end

def update_journal_subject(journal)
  puts "What do you want the new subject of the journal to be?"
  print "--> "
  new_subject = gets.chomp.titleize
  journal.update(subject: new_subject)
end

def entry_title_box(entry)
  pastel = Pastel.new
  puts pastel.decorate("Title", :blue, :bold)
  box = TTY::Box.frame "#{entry.title}", align: :center 
  print box
end

def entry_body_box(entry)
  pastel = Pastel.new
  puts pastel.decorate("Body", :blue, :bold)
  box = TTY::Box.frame "#{entry.body}", align: :center
  print box 
end 

divider
$user = get_user
divider
welcome($user)
single_divider
first_menu



