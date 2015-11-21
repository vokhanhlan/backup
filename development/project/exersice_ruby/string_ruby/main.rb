require './hello.rb'
require './service.rb'
class Main
  @arr_example =[
                  "a. Hello word: Thi is my first test.",
                  "b. Hello word: 10 characters",    
                  "c. Hello word: drow olleH", 
                  "d. Hello word: HELLO WORD",
                  "e. Hello word: Hello -> word",
                  "f. Hello word: Hell wrd",
                  "g. Hello word: H e l l o  w o r d",
                  "h. Hello word: Helo wrd", 
                  "i. Hello word: Heo word",   
                  "j. Hello word: Hello word 1 Hello word 2 Hello word 3 Hello word 4 Hello word 5",
                  "k. Hello word: Hello wor",
                  "l. Hello word: ello word",
                  "m. Hello word:               Hello word",
                  "n. Hello word: Hello         word",
                  "o. Hello word: word Hello"
                ]
  def self.run
    puts "*****************************************"
    puts "**************** TESTING ****************"
    puts "*****************************************\n"
    loop do
      puts " ========== SELECT FUCNTION =========  "
      puts " ======= Show list example: 1"
      puts " ======= THOAT: 0 \n"
      print "Please input value (0 -> 1):"
      list = gets.chomp
      if (list == "1")
        list_detail(@arr_example)
        print "Please input value (a -> o):"
        input = gets.chomp
        print "Please input work:"
        work = gets.chomp
        hello = Hello.new(work)
      else (input == "0")
        break
      end
#print input example
      case input
      when "a"
        puts hello.output_a
      when "b"
        puts hello.output_b
      when "c"
        puts hello.output_c
      when "d"
        puts hello.output_d
      when "e"
        puts hello.output_e
      when "f"
        puts hello.output_f
      when "g"
        puts hello.output_g
      when "h"
        puts hello.output_h
      when "j"
        puts hello.output_j
      when "k"
        puts hello.output_k
      when "l"
        puts hello.output_l
      when "l"
        puts hello.output_m
      else
        "" 
      end
      puts"\n\n\n" 
    end
  end
end
Main.run  