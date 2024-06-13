require 'json'

def verify_start_choice(startchoice)
   return true if startchoice == 1 || startchoice == 2
   puts "\nEnter a valid input!"
end

def verify_letter_choice(letter_choice)
  return true if letter_choice.count('a-z') == 1 || letter_choice == 'save'
  puts "\nPlease enter a single aphabetical character or the word 'save' to continue the game later!"
end

def get_word
  words = File.readlines('google-10000-english-no-swears.txt').map do |word|
    if word.count('a-z').between?(5,12)
      word
    end
  end
  
  return words.compact.sample
end

def choose_letter(incorrect_guesses)
  puts "\nMake every guess count! You only have #{8 - incorrect_guesses} left!"

  loop do
    print "\n\nEnter a letter, or type 'save' to preserve the current session for later: "
    guess = gets.chomp.downcase

    return guess if verify_letter_choice(guess)
  end
end

def initialize_game
  puts "Welcome to the game of Hangman!"
  sleep 3
  puts "\nTo win, you must choose letters that correspond to the randomly selected word."
  sleep 3
  puts "\nPick 8 incorrect letters, however, and it's game over!\n"
  sleep 3

  loop do
    print "\nWould you like to start a new game (1) or load a previous save (2): "
    start_choice = gets.chomp.to_i

    return start_choice if verify_start_choice(start_choice)
  end
end

def result(answer, incorrect_guesses)
  if !answer.include?("_")
    puts "You win! The word was #{word}."
    return true
  elsif incorrect_guesses == 8
    puts "Sorry, you ran out of guesses! The word was #{word}."
    return true
  end
end

def game(word, incorrect_guesses, guessed_letters, answer)
  puts "\e[H\e[2J"
  puts "\nStarting game!"
  sleep 3
  puts "\e[H\e[2J"
  
  loop do 
    puts "\nGuessed Letters: #{guessed_letters.join(", ")}"
    puts "\n"
    display_man(incorrect_guesses)
    puts "\n" + answer.join(" ").to_s
    
    guess = choose_letter(incorrect_guesses)

    if guess == 'save'
      File.open("save.txt", "w") { |f| f.write("#{word}\n#{incorrect_guesses}\n#{guessed_letters}\n#{answer}") }

      puts "\nSaving..."
      sleep 2
      puts "\nGame saved! See you soon!"
      break
    elsif word.include?(guess) && !guessed_letters.include?(guess)
      word.split("").each_with_index do |letter, index|
        if letter == guess
          answer[index] = letter
        end
      end
      
      guessed_letters << guess
      
      puts "\nCorrect! The mystery word includes the letter #{guess}."
      sleep 3
      puts "\e[H\e[2J"
    elsif !word.include?(guess) && !guessed_letters.include?(guess)
      incorrect_guesses += 1
      guessed_letters << guess

      puts "\nSorry! The mystery word does not include the letter #{guess}."
      sleep 3
      puts "\e[H\e[2J"
    elsif guessed_letters.include?(guess)
      puts "\nYou already chose that letter! Try again."
      sleep 3
      puts "\e[H\e[2J"
      next
    end

    break if result(answer, incorrect_guesses)
  end
end

def display_man(incorrect_guesses)
  case incorrect_guesses
    
  when 0
    puts ''
  when 1
    puts "|\n|\n|\n|\n|\n|"
  when 2
    puts "________\n|      |\n|\n|\n|\n|\n|"
  when 3
    puts "________\n|      |\n|      O\n|\n|\n|\n|"
  when 4
    puts "________\n|      |\n|      O\n|      |\n|\n|\n|"
  when 5
    puts "________\n|      |\n|      O\n|     /|\n|\n|\n|"
  when 6
    puts "________\n|      |\n|      O\n|     /|\\\n|\n|\n|"
  when 7
    puts "________\n|      |\n|      O\n|     /|\\\n|     /\n|\n|"
  when 8
    puts "________\n|      |\n|      O\n|     /|\\\n|     / \\\n|\n|"
  end
end

def play
  word = get_word
  incorrect_guesses = 0
  guessed_letters = []
  answer = Array.new(word.length-1){'_'}
  
  if initialize_game == 1
    game(word, incorrect_guesses, guessed_letters, answer)
  else
    save_content = File.readlines('save.txt').map(&:chomp)
    
    word = save_content[0]
    incorrect_guesses = save_content[1].to_i
    guessed_letters = JSON.parse(save_content[2])
    answer = JSON.parse(save_content[3])

    puts "\nLoading..."
    sleep 2
    puts "\nLoad Successful!"
    sleep 2
    
    game(word, incorrect_guesses, guessed_letters, answer)
  end
end

play