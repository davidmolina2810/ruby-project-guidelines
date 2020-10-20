require_relative '../config/environment'

def determine_user
  puts "Please enter your name"
  name = gets.chomp
  Writer.find_by(username: name)
end

def welcome
  pastel = Pastel.new
  puts pastel.decorate("Welcome to your Journal Explorer!", :green, :bold)
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

  

welcome 
user = determine_user
puts user.entries.first.body
divider
#first_menu_box



