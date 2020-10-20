require_relative '../config/environment'

def determine_user
  puts "Please enter your username: "
  name = gets.chomp
  Writer.find_by(username: name)
end

def welcome(user)
  pastel = Pastel.new
  puts pastel.decorate("Welcome to your Journal Explorer, #{user.username}!", :green, :bold)
end

def divider
  puts "==========================="
end

def first_menu_box 
  box = TTY::Box.frame "1. Create new Journal", "2. Open a Journal", "3. Delete Journal", align: :left
  print box 
end

def create_writer(name)
end

  

user = determine_user
welcome(user)
divider
puts "What would you like to do?"
first_menu_box

choice = gets.chomp.to_i

if choice == 1

  puts "What do you want to call this journal?"
  journal_name = gets.chomp
  puts "Do you want to add a subject? (Y/N) "
  choice = gets.chomp.upcase
  if choice == "Y"
    puts "What subject should this journal be?"
    subject = gets.chomp.capitalize
    user.create_journal(journal_name, subject)
  else
    user.create_journal(journal_name)
  end 

elsif choice == 2
  journal_names = user.journals.uniq.map{ |journal| journal.name}
  binding.pry
end



