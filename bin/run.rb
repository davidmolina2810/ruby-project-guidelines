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

  first_menu_box
  puts "What would you like to do?"  
  choice = gets.chomp.to_i

  single_divider
  if choice == 1
    create_journal


  elsif choice == 2
    journal = open_journal
    show_entries(journal)

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

def first_menu_box 
  box = TTY::Box.frame "1. Create new Journal", "2. Open a Journal", "3. Delete Journal", align: :left
  print box 
end

def open_journal
  journal_names = $user.journals.uniq.map{ |journal| journal.name }
  for x in (1..journal_names.length) do 
    puts "#{x}. #{journal_names[x-1]}"
  end
  single_divider
  print "Select a journal number: "
  num = gets.chomp.to_i
  single_divider
  puts "Opening #{journal_names[num-1]}..."
  divider
  puts "Here are the entries in this journal:"
  journal = $user.journals.find_by(name: journal_names[num-1])
end

def show_entries(journal)
  entries = journal.entries
  if !entries.empty?
    puts "Entry No.     Entry Title"
    single_divider
    for x in (1..entries.length) do 
      puts "   #{x}.           #{entries[x-1].title}"
    end
  end
end

def create_journal
  puts "What do you want to call this journal?"
  journal_name = gets.chomp
  puts "Do you want to add a subject? (Y/N) "
  choice = gets.chomp.upcase
  if choice == "Y"
    puts "What subject should this journal be?"
    subject = gets.chomp.capitalize
    $user.create_journal(journal_name, subject)
    single_divider
    puts "New journal, '#{journal_name}', of subject, '#{subject}', created."
  else
    $user.create_journal(journal_name)
    single_divider
    puts "New journal, '#{journal_name}', created."
  end 
end


$user = get_user
welcome($user)
divider
first_menu



