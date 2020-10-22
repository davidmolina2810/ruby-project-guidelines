require_relative '../config/environment'
require 'pry'
$pastel = Pastel.new


def logo 
  font = TTY::Font.new(:doom)
  puts $pastel.magenta.bold("
                                            ''~ ``
                                            ( o o )
                    +------------------.oooO--(_)--Oooo.------------------+")
  puts $pastel.green.bold(font.write("Journal Explorer"))
  puts $pastel.magenta.bold("
                                       .oooO                            
                                       (   )    Oooo.                    
                   +---------------------\ (----(   )--------------------+
                                          \_)    ) /
                                                (_/ ")
end

def get_user # if username not associated with a Writer, return false, else return the Writer instance
  prompt = TTY::Prompt.new
  print $pastel.green.bold ("Enter your username: ")
  username = gets.chomp
  password = prompt.mask pastel.green.bold ("Enter your password:")
  if get_writer_by_user_and_pass(username, password) == nil
    print pastel.green.bold "Hmm... I can't find you. Are you a new writer? (Y/N) "
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

def page_break
  puts "\n" * 35
end

def welcome(user)
  puts $pastel.decorate("Welcome to your Journal Explorer, #{user.username}!", :yellow, :bold)
end

def first_menu 
    choice = prompt_menu_input(home_menu_box) # 1. Create Journal, 2. View your Journals, 3. Exit
    puts
    puts
  
  if choice == 1 # create a new journal and associates to $user by creating first entry
    create_and_associate_journal
   

  elsif choice == 2 # view all journals by this user
    page_break
    this_users_journals = show_journals
    choice = prompt_menu_input(view_journals_menu_box) # 1. Open a journal, 2. edit a journal, 3. Delete a journal
    

    if choice == 1 # open a journal
      journal = select_journal(this_users_journals)
      entries_in_this_journal = show_entries(journal)
      user_choice = prompt_menu_input(entries_edit_menu_box) # 1. Write entry, 2. view entry, 3. edit entry, 4. delete entry
      
      if user_choice == 1 # write an entry
        write_entry(journal)

      elsif user_choice == 2 # view an entry 
        page_break
        entry = select_entry(entries_in_this_journal)
        view_entry(entry)

      elsif user_choice == 3  # edit an entry
        page_break
        entry = select_entry(entries_in_this_journal)
        puts $pastel.magenta("Current Entry")
        view_entry(entry)
        answer = prompt_menu_input(entry_edit_menu_box, "What do you want to change about entry, #{entry.title}?")

        if answer == 1 # change entry title only
          update_entry_title(entry)
          view_updated_entry(entry)
        elsif answer == 2 # change entry body only
          update_entry_body(entry)
          view_updated_entry(entry)
        elsif answer == 3 # change entry title and body 
          update_entry_title(entry)
          update_entry_body(entry)
          view_updated_entry(entry)
        end

      elsif user_choice == 4 # delete an entry
        entry = select_entry(entries_in_this_journal)
        puts "Destroyed entry, #{entry.title}"
        entry.destroy
      end


    elsif choice == 2 # edit a journal
      journal = select_journal(this_users_journals)
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
      journal = select_journal(this_users_journals)
      delete_journal(journal)
    end
  
  elsif choice == 3 # exit program
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
  page_break
  divider
  if !$user.journals.include?(journal) # if new journal has not been associated with $user bc no entry has been made
    puts $pastel.yellow.bold "Let's make your first entry in #{journal.name}!"
    puts
    puts
    write_entry(journal)
  end
  divider
end



def prompt_menu_input(box, prompt = "What would you like to do?") # prompts user, prints box menu, returns choice as Int
  puts $pastel.yellow.bold prompt
  box
  print $pastel.yellow.bold "--> "
  choice = gets.chomp.to_i
end

def write_entry(journal)
  print $pastel.yellow.bold "Can you think of a title for you entry? (Y/N) "
  resp = gets.chomp.upcase
  if resp == "Y"
    write_entry_with_title(journal)
  elsif resp == "N"
    write_entry_without_title(journal)
  end
end

def create_writer
  pastel = Pastel.new 
  prompt = TTY::Prompt.new
  puts pastel.red.bold "You are making a new account."
  print pastel.green.bold "Enter a username: "
  username = gets.chomp
  password = prompt.mask pastel.green.bold ("Enter your password:")
  Writer.create(username: username, password: pass)
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


def home_menu_box 
  box = TTY::Box.frame "1. Create new Journal", "2. View Your Journals", "3. Exit", align: :left
  print $pastel.green.bold box 
  single_divider
end

def view_journals_menu_box
  box = TTY::Box.frame "1. Open a journal", "2. Edit a journal", "3. Delete a journal", align: :left
  print $pastel.green.bold box
  single_divider
end

def journal_edit_menu_box
  box = greenify(TTY::Box.frame "1. Change journal name", "2. Change journal subject", "3. Both", "4. Back", align: :left)
  print box
  single_divider
end

def entries_edit_menu_box
  box = greenify(TTY::Box.frame "1. Write an entry", "2. View an entry", "3. Edit an entry", "4. Delete an entry", 
  "5. Back", align: :left)
  print box
end

def entry_edit_menu_box
  box = greenify(TTY::Box.frame "1. Change title", "2. Change body", "3. Both", "4. Back", align: :left)
  print box
end

def show_journals # show all journals' names by $user and return journals
  puts "Here are your journals: "
  divider
  journals = $user.journals.uniq
  journals.each {|journal| journal_box(journal)}
  #if !journals.empty?
    #puts "Title".rjust(10) + "Subject".rjust(22)
    #puts "-----".rjust(10) + "-------".rjust(22)
    #for x in (1..journals.length) do 
      #puts "#{x}".ljust(5) + "#{journals[x-1].name}".ljust(20) + "#{journals[x-1].subject}".ljust(18)
    #end
  #end
  divider
  journals
end

def select_journal_by_name(journals)
  print "Enter the exact Journal name"
  print "--> "
end

def select_journal(journals) # get one journal instance
  print "Select a journal number: "
  num = gets.chomp.to_i
  page_break
  single_divider
  journal = journals[num-1]
  puts $pastel.yellow.bold "Opening #{journal.name}..."
  divider
  journal 
end

def select_entry(entries) # get one entry instance
  puts $pastel.yellow.bold "Select an entry number: "
  print $pastel.yellow.bold "--> "
  num = gets.chomp.to_i
  entry = entries[num-1]
  puts $pastel.yellow.bold "Selecting entry, #{entry.title}..."
  single_divider
  entry
end


def show_entries(journal) # show all entries by $user in journal and return entries
  puts $pastel.yellow.bold "Here are the entries in this journal:"
  divider
  entries = journal.entries
  if !entries.empty?
    puts $pastel.yellow.bold "No.      Title"
    puts $pastel.yellow.bold "---      -----"
    for x in (1..entries.length) do 
      puts $pastel.yellow.bold "#{x}.      #{entries[x-1].title}"
    end
  end
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
  else
    journal = $user.create_journal(journal_name)
    single_divider
    puts $pastel.yellow.bold "New journal, '#{journal_name}', created."
    journal
  end 
end

def delete_journal(journal) # delete given journal from db
  puts $pastel.red.bold"Destroyed journal, #{journal.name}."
  entries = Entry.all.select{ |entry| entry.journal_id == journal.id }
  entries.each { |entry| entry.destroy }
  journal.destroy
end

def write_entry_with_title(journal)
  puts
  print $pastel.yellow.bold "Awesome! Enter your entry's title here: "
  title = gets.chomp.titleize
  puts $pastel.yellow.bold "Type your entry below. Hitting enter will end your current writing session and save your entry."
  puts
  body = gets.chomp
  $user.write_entry(journal, body, title)
end

def write_entry_without_title(journal)
  page_break
  puts $pastel.yellow.bold "No worries! Many writers don't put a title on their books until they've written the last page!"
  puts
  puts $pastel.yellow.bold "Let's get started on your entry."
  single_divider
  puts $pastel.yellow.bold "Type your entry below. Hitting enter will end your current writing session and save your entry."
  puts
  body = gets.chomp
  $user.write_entry(journal, body)
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
  puts $pastel.yellow.bold "Type your new entry below"
  print $pastel.yellow.bold "--> "
  new_body = gets.chomp
  puts
  entry.update(body: new_body)
end

def entry_title_box(entry)
  puts $pastel.decorate("Title", :blue, :bold)
  box = TTY::Box.frame $pastel.green("#{entry.title}"), align: :center
  print box
end

def entry_body_box(entry)
  label = $pastel.decorate("Body", :blue, :bold)
  puts label
  box = TTY::Box.frame $pastel.yellow("#{entry.body}"), align: :center
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
  single_divider
  view_entry(entry)
end


#divider
logo
$user = get_user
page_break
divider
welcome($user)
single_divider
first_menu




