require_relative '../config/environment'
require 'readline'
require 'pry'

$pastel = Pastel.new

class JournalExplorer

  def logo 
    divider
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
    choice = prompt.yes?("Are you a new writer?")
    if choice  # new user
      return create_writer
    elsif !choice # user should be in db
      username = prompt.ask($pastel.green.bold "Enter your username: ")
      password = prompt.mask $pastel.green.bold ("Enter your password: ")
      get_writer_by_user_and_pass(username, password)
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
    choices = %w(Login Quit)
    choice = prompt_menu_input(choices, "Welcome! What would you like to do?")
    if choice == "Login" # login
      $user = get_user
      progress_bar("Logging in")
      welcome($user)
      home_menu
    elsif choice == "Quit" # quit
      exit_program
    else
      incorrect_return_to(start_program) # if 1 or 2 not chosen, call start_program
    end
  end

  def home_menu(quote = nil) 
    choices = ["Create Journal", "View your Journals", "Exit"]
    if !quote
      page_break
      choice = prompt_menu_input(choices) # 1. Create Journal, 2. View your Journals, 3. Exit
    elsif quote
      page_break
      choice = prompt_menu_input(choices, quote)
    end
    puts
    puts
    if choice == "Create Journal" # create a new journal and associates to $user by creating first entry
      create_and_associate_journal
    elsif choice == "View your Journals" # view all journals by this user
      progress_bar("Pulling up your journals")
      journals_menu
    elsif choice == "Exit" # exit program
      exit_program
    else 
      incorrect_return_to(home_menu) # if 1, 2, or 3 not chosen, call and return to home_menu
    end
  end

  def animation
    2.times do #however many times you want it to go for
    i = 0
      while i < 9
        print ("\033[2J")     
        File.foreach("animation1.rb/#{i}.rb") { |f| puts f }
        sleep(0.08) #how long it is displayed for
        i += 1
      end
    end
  end

  def progress_bar(action, redify = false, affirm = "Done!")
    page_break
    if !redify 
      bar = ProgressBar.create(:title => $pastel.bright_cyan.bold(action), :total => nil, :length => 50, :unknown_progress_animation_steps => ['==>', '>==', '=>='], :throttle_rate => 0.1)
      50.times { bar.increment; sleep(0.03) }
      page_break
      if affirm
        puts $pastel.bright_cyan.bold(affirm)
      end
    elsif redify && affirm
      bar = ProgressBar.create(:title => $pastel.red.bold(action), :total => nil, :length => 50, :unknown_progress_animation_steps => ['==>', '>==', '=>='], :throttle_rate => 0.1)
      50.times { bar.increment; sleep(0.03) }
      page_break
      puts $pastel.red.bold(affirm)
    end
    puts
    puts
  end

  def exit_program # end program
    animation
    exit
  end

  def journals_menu
    choices = ["Open a Journal", "Edit a Journal", "Delete a Journal", "Go back", "Exit"]
    this_user_journals = show_journals
    choice = prompt_menu_input(choices) # 1. Open a journal, 2. edit a journal, 3. Delete a journal, 4. Go Back

    if choice == "Open a Journal" # open a journal
      journal = select_journal(this_user_journals) 
      entries_menu(journal)

    elsif choice == "Edit a Journal" # edit a journal
      journal = select_journal(this_user_journals)
      edit_journals_menu(journal, this_user_journals)    
      
    elsif choice == "Delete a Journal" # delete a journal
      journal = select_journal(this_user_journals)
      delete_journal(journal)
    
    elsif choice == "Go back" # call first_menu to go back to home menu
      page_break
      progress_bar("Returning to previous menu")
      $reload
      loop_to_home_menu_box
    elsif choice == "Exit"
      exit_program
    end
  end

  def edit_journals_menu(journal, journals) # logic end
    choices = ["Change name of Journal", "Go back", "Exit"]
    choice = prompt_menu_input(choices)

    if choice == "Change name of Journal" # change name of journal
      update_journal_name(journal)

    elsif choice == "Go back" # go back to previous menu
      progress_bar("Returning to previous menu")
      journals_menu
    elsif choice == "Exit" # exit program
      exit_program
    end
  end

  def entries_menu(journal)
    choices = ["Write entry", "View entry", "Edit entry", "Delete entry", "Go back", "Exit"]
    entries_in_this_journal = show_entries(journal)
    choice = prompt_menu_input(choices) # 1. Write entry, 2. view entry, 3. edit entry, 4. delete entry

    if choice == "Write entry" # write an entry
      entry = write_entry(journal)
      puts $pastel.cyan("Your new entry")
      view_entry(entry)
      loop_to_home_menu_box

    elsif choice == "View entry" # view an entry 
      entry = select_entry(entries_in_this_journal)
      puts $pastel.cyan("Your entry")
      view_entry(entry)
      loop_to_home_menu_box

    elsif choice == "Edit entry"  # edit an entry
      entry = select_entry(entries_in_this_journal)
      edit_entries_menu(entry, journal)
      loop_to_home_menu_box
    
    elsif choice == "Delete entry" # delete an entry
      entry = select_entry(entries_in_this_journal)
      puts $pastel.red("Destroyed entry, #{entry.title}")
      entry.destroy
      loop_to_home_menu_box

    elsif choice == "Go back" # back to previous menu
      page_break
      progress_bar("Returning to previous menu")
      journals_menu

    elsif choice == "Exit" # exit program
      exit_program
    end
  end

  def edit_entries_menu(entry, journal)
    choices = ["Change only entry title", "Change only entry body", "Change both", "Go back", "Exit"]
    puts $pastel.magenta("Current Entry")
    view_entry(entry)
    choice = prompt_menu_input(choices, "What do you want to change about entry, #{entry.title}?")

    if choice == "Change only entry title" # change entry title only
      update_entry_title(entry)
      view_updated_entry(entry)
    elsif choice == "Change only entry body" # change entry body only
      update_entry_body(entry)
      view_updated_entry(entry)
    elsif choice == "Change both" # change entry title and body 
      update_entry_title(entry)
      update_entry_body(entry)
      view_updated_entry(entry)
    
    elsif choice == "Go back" # go back to previous menu
      page_break
      progress_bar("Going back to previous menu")
      entries_menu(journal)
    elsif choice == "Exit" # exit program
      exit_program
    end
  end

  def incorrect_return_to(method)
    single_divider
    puts $pastel.red "Incorrect input. Try again."
    single_divider
    progress_bar("Starting over")
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
      home_menu
      #loop_to_home_menu_box
    end
  end

  def prompt_menu_input(choices, prompt_message = "What would you like to do?") # prompts user, prints box menu, returns choice as Int
    prompt = TTY::Prompt.new
    #puts $pastel.yellow.bold prompt
    #box
    #print $pastel.yellow.bold "--> "
    #choice = gets.chomp.to_i
    choice = prompt.select(prompt_message, choices)
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
    page_break
    body = body.join("\n") # return body as string with each line joined by \n 
  end

  def show_journals # show all journals' names by $user and return journals
    puts
    puts $pastel.yellow.bold "Here are your journals: "
    divider
    journals = $user.journals.uniq
    #binding.pry
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
    divider
    page_break
    progress_bar("Opening '#{journal.name}'")
    journal 
  end


  def select_entry(entries) # get one entry instance
    puts $pastel.yellow.bold "Select an entry number: "
    print $pastel.yellow.bold "--> "
    num = gets.chomp.to_i
    entry = entries[num-1]
    progress_bar("Fetching your entry:")
    entry
  end


  def show_entries(journal) # show all entries by $user in journal and return entries
    puts
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
    else
      puts $pastel.yellow.bold "You haven't written any entries yet."
      prompt = TTY::Prompt.new
      choice = prompt.yes?("Would you like to write one?").upcase

      if choice == "Y"
        write_entry(journal)
      elsif choice == "N"
        puts "Okay. No problem."
      else
        incorrect_return_to(show_entries(journal))
      end
    end
    divider
    entries
  end

  def create_journal
    puts $pastel.yellow.bold "What do you want to call this journal?"
    print $pastel.yellow.bold "--> "
    journal_name = gets.chomp.titleize
    #puts $pastel.yellow.bold "Do you want to add a subject? (Y/N) "
    #print $pastel.yellow.bold "--> "
    #choice = gets.chomp.upcase
    #if choice == "Y"
      #puts $pastel.yellow.bold "What subject should this journal be?"
      #print $pastel.yellow.bold "--> "
      #subject = gets.chomp.capitalize
      #journal = $user.create_journal(journal_name, subject)
      #single_divider
      #puts $pastel.yellow.bold "New journal, '#{journal_name}', of subject, '#{subject}', created."
      #journal
    #elsif choice == "N"
    journal = $user.create_journal(journal_name)
    single_divider
    puts $pastel.yellow.bold "New journal, '#{journal_name}', created."
    journal
  end

  def delete_journal(journal) # delete given journal from db
    progress_bar("Destroying '#{journal.name}'", true, "Journal Destroyed.")
    entries = journal.entries
    entries.each { |entry| entry.destroy }
    journal.destroy
    loop_to_home_menu_box
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
    body = capture_entry_body
    $user.write_entry(journal, body)
  end

  def update_journal_name(journal)
    puts $pastel.yellow.bold "What would you like the new name to be?"
    print $pastel.yellow.bold "--> "
    new_name = gets.chomp.titleize
    puts
    journal.update(name: new_name)
    loop_to_home_menu_box
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
    box = TTY::Box.frame $pastel.green(body), align: :left
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

  def loop_to_home_menu_box # with a different prompt
    choices = %w(Continue Exit)
    self.reload
    choice = prompt_menu_input(choices, "Continue or Exit program?")
    if choice == "Continue" || choice == "continue"
      quote = "Great! What would you like to do next?"
      progress_bar("Returning to Home menu", false, quote)
      home_menu 
      divider
    elsif choice == "Exit" || choice == "exit"
      exit_program
    else
      incorrect_return_to(loop_to_home_menu_box)
    end
  end

  def reload
    prompt = TTY::Prompt.new
    prompt.yes?("Reload?")
  end


  def initialize
    logo
    puts
    puts
  end
end

journalexplorer = JournalExplorer.new
until journalexplorer.reload
  journalexplorer.start_program
end


