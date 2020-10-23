require_relative '../config/environment'
require 'readline'

$pastel = Pastel.new
$end_prog = false

def logo 
  font = TTY::Font.new(:doom)
  puts $pastel.magenta.bold("
  
                                            ''~ ``
                                            ( o o )
                    +------------------.oooO--(_)--Oooo.------------------+")
                    
  puts $pastel.green.bold(font.write("Journal Explorer"))
  puts $pastel.magenta.bold"
                                        .oooO                            
                                        (   )    Oooo.                    
                    +---------------------\ (----(   )--------------------+
                                           \_)    ) /
                                                 (_/ "

end

def get_user # if username not associated with a Writer, return false, else return the Writer instance
  prompt = TTY::Prompt.new
  print $pastel.green.bold ("Enter your username: ")
  username = gets.chomp
  password = prompt.mask $pastel.green.bold ("Enter your password:")
  if get_writer_by_user_and_pass(username, password) == nil
    print $pastel.green.bold "Hmm... I can't find you. Are you a new writer? (Y/N) "
    choice = gets.chomp.upcase
    if choice == 'Y'
      return create_writer
    elsif choice == 'N'
      get_user
    else
    end
  else
    return get_writer_by_user_and_pass(username, password)
  end
end

def page_break
  puts "\n" * 35
end

def welcome(user)
  divider
  puts $pastel.decorate("Welcome to your Journal Explorer, #{user.username}!", :yellow, :bold)
  divider
end

def start_program
  choice = prompt_menu_input(initialize_menu_box, "Choose a number")
  if choice == 1 # login
    $user = get_user
    home_menu
  elsif choice == 2 # quit
    exit_program
  else
    incorrect_return_to(start_program) # if 1 or 2 not chosen, call start_program
  end
end

def initialize_menu_box
  box = TTY::Box.frame "1. Login", "2. Quit", align: :left
  print $pastel.green.bold box
end

def home_menu 
  page_break
  welcome($user)
  choice = prompt_menu_input(home_menu_box) # 1. Create Journal, 2. View your Journals, 3. Exit
  puts
  puts
  page_break
  
  if choice == 1 # create a new journal and associates to $user by creating first entry
    create_and_associate_journal

  elsif choice == 2 # view all journals by this user
    journals_menu
    
  elsif choice == 3 # exit program
    exit_program
  else 
    incorrect_return_to(home_menu) # if 1, 2, or 3 not chosen, call and return to home_menu
  end
end

def exit_program
  puts "Goodbye.\n\n\n\n"
  exit
end

def journals_menu
  this_user_journals = show_journals
  choice = prompt_menu_input(view_journals_menu_box) # 1. Open a journal, 2. edit a journal, 3. Delete a journal, 4. Go Back

  if choice == 1 # open a journal
    journal = select_journal(this_user_journals)
    page_break
    
    
    entries_menu(journal)
    


  elsif choice == 2 # edit a journal
    journal = select_journal(this_user_journals)
    

    edit_journals_menu(journal, this_user_journals)
    
    
  elsif choice == 3 # delete a journal
    journal = select_journal(this_user_journals)
    delete_journal(journal)
  
  elsif choice == 4 # call first_menu to go back to home menu
    page_break
    home_menu
  elsif choice == 5
    exit_program
  end
end

def edit_journals_menu(journal, journals)
  choice = prompt_menu_input(journal_edit_menu_box, "What do you want to change about #{journal.name}?")

  if choice == 1 # change name of journal
    update_journal_name(journal)

  elsif choice == 2 # change subject of journal
    update_journal_subject(journal)

  elsif choice == 3 # change both subject and name 
    update_journal_name(journal)
    update_journal_subject(journal)
  elsif choice == 4 # go back to previous menu
    page_break
    journals_menu
  elsif choice == 5 # exit program
    exit_program
  end
end

def entries_menu(journal)
  entries_in_this_journal = show_entries(journal)
  choice = prompt_menu_input(entries_edit_menu_box) # 1. Write entry, 2. view entry, 3. edit entry, 4. delete entry

  if choice == 1 # write an entry
    entry = write_entry(journal)
    puts $pastel.cyan("Your new entry")
    view_entry(entry)

  elsif choice == 2 # view an entry 
    entry = select_entry(entries_in_this_journal)
    puts $pastel.cyan("Your entry")
    view_entry(entry)

  elsif choice == 3  # edit an entry
    entry = select_entry(entries_in_this_journal)
    edit_entries_menu(entry, journal)
    

  elsif choice == 4 # delete an entry
    entry = select_entry(entries_in_this_journal)
    puts $pastel.red("Destroyed entry, #{entry.title}")
    entry.destroy
  elsif choice == 5 # back to previous menu
    page_break
    journals_menu
  elsif choice == 6. # exit program
    exit_program
  end
end

def edit_entries_menu(entry, journal)
  puts $pastel.magenta("Current Entry")
  view_entry(entry)
  choice = prompt_menu_input(entry_edit_menu_box, "What do you want to change about entry, #{entry.title}?")

  if choice == 1 # change entry title only
    update_entry_title(entry)
    view_updated_entry(entry)
  elsif choice == 2 # change entry body only
    update_entry_body(entry)
    view_updated_entry(entry)
  elsif choice == 3 # change entry title and body 
    update_entry_title(entry)
    update_entry_body(entry)
    view_updated_entry(entry)
  
  elsif choice == 4 # go back to previous menu
    page_break
    entries_menu(journal)
  elsif choice == 5 # exit program
    exit_program
  end
end

def incorrect_return_to(method)
  single_divider
  puts $pastel.red "Incorrect input. Try again."
  single_divider
  method
end

def create_and_associate_journal
  journal = create_journal
  page_break
  divider
  if !$user.journals.include?(journal) # if new journal has not been associated with $user bc no entry has been made
    puts $pastel.yellow.bold "Let's make your first entry in #{journal.name}!"
    puts
    puts
    entry = write_entry(journal)
    view_entry(entry)
  end
end

def prompt_menu_input(box, prompt = "What would you like to do?") # prompts user, prints box menu, returns choice as Int
  puts $pastel.yellow.bold prompt
  box
  print $pastel.yellow.bold "--> "
  choice = gets.chomp.to_i
end

def write_entry(journal)
  print $pastel.yellow.bold "Can you think of a title for you entry? (Y/N) "
  print $pastel.yellow.bold "--> "
  resp = gets.chomp.upcase
  if resp == "Y"
    write_entry_with_title(journal)
  elsif resp == "N"
    write_entry_without_title(journal)
  else
    single_divider
    puts $pastel.red "Incorrect input. Try again."
    single_divider
    write_entry(journal)
  end
end

def create_writer
  prompt = TTY::Prompt.new
  puts $pastel.red.bold "You are making a new account."
  print $pastel.green.bold "Enter a username: "
  username = gets.chomp
  password = prompt.mask $pastel.green.bold ("Enter your password:")
  Writer.create(username: username, password: password)
end

def get_writer_by_user_and_pass(username, password) # return Writer that matches username and password
  Writer.find_by(username: username, password: password)
end

def divider
  puts $pastel.magenta "========================================================================================================"
end

def single_divider
  puts $pastel.magenta "--------------------------------------------------------------------------------------------------------"
end

def capture_entry_body # keep input open until writer executes CTRL C, returns body with added newlines
  body = [] # will hold each line of the body
  divider
  puts "Write your entry below."
  puts "Hit enter for new line."
  puts "To end session, execute CTRL + C."
  puts
  prompt = $pastel.yellow.bold "∑==> " # prompt to be output each newline while writing entry
  begin
    while buf = Readline.readline(prompt, true) # enter interactive writing session to allow ENTER to create newline in body
      body << buf # add buf (text input up until ENTER) to array body 
    end
  rescue Interrupt # error handler 
    puts "\nWriting session ended."
  end
  divider
  body = body.join("\n") # return body as string with each line joined by \n 
end

def home_menu_box 
  box = TTY::Box.frame "1. Create new Journal", "2. View Your Journals", "3. Exit", align: :left
  print $pastel.green.bold box 
  single_divider
end

def view_journals_menu_box
  box = TTY::Box.frame "1. Open a journal", "2. Edit a journal", "3. Delete a journal", "4. Back", "5. Exit", align: :left
  print $pastel.green.bold box
  single_divider
end

def journal_edit_menu_box
  box = TTY::Box.frame "1. Change journal name", "2. Change journal subject", "3. Both", "4. Back", "5. Exit", align: :left
  print $pastel.green.bold box
  single_divider
end

def entries_edit_menu_box
  box = TTY::Box.frame "1. Write an entry", "2. View an entry", "3. Edit an entry", "4. Delete an entry", 
  "5. Back", "6. Exit", align: :left
  print $pastel.green.bold box
  single_divider
end

def select_journal_by_name(journals)
  print "Enter the exact Journal name"
  print "--> "
end

def select_journal(journals) # get one journal instance
  print "Select a journal number: "
  box = TTY::Box.frame "1. Write an entry", "2. View an entry", "3. Edit an entry", "4. Delete an entry", align: :left
  print $pastel.green.bold box
end

def entry_edit_menu_box
  box = TTY::Box.frame "1. Change title", "2. Change body", "3. Both", "4. Back", align: :left
  print $pastel.green.bold box
end

def show_journals # show all journals' names by $user and return journals
  puts $pastel.yellow.bold "Here are your journals: "
  divider
  journals = $user.journals.uniq
  if !journals.empty?
    puts $pastel.yellow.bold "Title".center(43)
    puts $pastel.yellow.bold "-----".center(43)
    for x in (1..journals.length) do 
      puts $pastel.yellow.bold "#{x}." + "#{journals[x-1].name}".center(40)
    end
  end
  journals
end

def select_journal(journals) # get one journal instance
  print $pastel.yellow.bold "Select a journal number: "
  num = gets.chomp.to_i
  single_divider
  journal = journals[num-1]
  puts $pastel.yellow.bold "Opening #{journal.name}..."
  divider
  page_break
  journal 
end


def select_entry(entries) # get one entry instance
  puts $pastel.yellow.bold "Select an entry number: "
  print $pastel.yellow.bold "--> "
  num = gets.chomp.to_i
  entry = entries[num-1]
  puts $pastel.yellow.bold "Selecting entry, #{entry.title}..."
  single_divider
  page_break
  entry
end


def show_entries(journal) # show all entries by $user in journal and return entries
  puts $pastel.yellow.bold "Here are the entries in this journal:"
  divider
  entries = journal.entries
  if !entries.empty?
    puts $pastel.yellow.bold("Title".center(40) + "Word Count".center(20))
    puts $pastel.yellow.bold("-----".center(40) + "----------".center(20))
    for x in (1..entries.length) do 
      entry = entries[x-1]
      puts $pastel.yellow.bold("#{x}." + "#{entry.title}".center(36) + "#{entry.word_count}".center(21))
    end
  end
  divider
  entries
end

def create_journal
  puts $pastel.yellow.bold "What do you want to call this journal?"
  print $pastel.yellow.bold "--> "
  journal_name = gets.chomp
  puts $pastel.yellow.bold "Do you want to add a subject? (Y/N) "
  print $pastel.yellow.bold "--> "
  choice = gets.chomp.upcase
  if choice == "Y"
    puts $pastel.yellow.bold "What subject should this journal be?"
    print $pastel.yellow.bold "--> "
    subject = gets.chomp.capitalize
    journal = $user.create_journal(journal_name, subject)
    single_divider
    puts $pastel.yellow.bold "New journal, '#{journal_name}', of subject, '#{subject}', created."
    journal
  elsif choice == "N"
    journal = $user.create_journal(journal_name, "(No Subject)")
    single_divider
    puts $pastel.yellow.bold "New journal, '#{journal_name}', created."
    journal
  else
    incorrect_return_to(create_journal)
  end 
end

def delete_journal(journal) # delete given journal from db
  puts $pastel.red.bold"Destroyed journal, #{journal.name}."
  entries = Entry.all.select{ |entry| entry.journal_id == journal.id }
  entries.each { |entry| entry.destroy }
  journal.destroy
end

def write_entry_with_title(journal)
  single_divider
  puts
  print $pastel.yellow.bold "Awesome! Enter your entry's title here: "
  print $pastel.yellow.bold "--> "
  title = gets.chomp.titleize
  puts
  body = capture_entry_body
  $user.write_entry(journal, body, title)
end

def write_entry_without_title(journal)
  page_break
  puts $pastel.yellow.bold "No worries! Many writers don't put a title on their books until they've written the last page!"
  puts
  puts $pastel.yellow.bold "Now, let's get started on your entry."
  single_divider
  body = capture_entry_body
  $user.write_entry(journal, body, "(Untitled)")
end

def update_journal_name(journal)
  puts $pastel.yellow.bold "What would you like the new name to be?"
  print $pastel.yellow.bold "--> "
  new_name = gets.chomp.titleize
  puts
  journal.update(name: new_name)
end

def update_journal_subject(journal)
  puts $pastel.yellow.bold "What would you like the new subject of this journal to be?"
  print $pastel.yellow.bold "--> "
  new_subject = gets.chomp.titleize
  puts
  journal.update(subject: new_subject)
end

def update_entry_title(entry)
  puts $pastel.yellow.bold "What would you like the new title of this entry to be?"
  print $pastel.yellow.bold "--> "
  new_title = gets.chomp.titleize
  puts
  entry.update(title: new_title)
end

def update_entry_body(entry)
  new_body = capture_entry_body
  puts
  entry.update(body: new_body)
end

def entry_title_box(entry)
  puts $pastel.decorate("Title", :blue, :bold)
  box = TTY::Box.frame $pastel.green("#{entry.title}"), align: :center
  print box
end

def entry_body_box(entry) # print out the body of an entry in blue inside a white box
  body = entry.body
  puts $pastel.decorate("Body", :blue, :bold)
  box = TTY::Box.frame $pastel.green(body), align: :center
  print box 
end 

def journal_box(journal)
  box = TTY::Box.frame $pastel.decorate(journal.name, :bold)
  print box
end

def view_entry(entry)
  divider
  entry_title_box(entry)
  entry_body_box(entry)
  divider
end

def view_updated_entry(entry)
  puts $pastel.red.bold("Your updated Entry")
  view_entry(entry)
end

def run
  #until $end_prog  
  divider
  logo
  puts
  puts
  start_program
end

run



