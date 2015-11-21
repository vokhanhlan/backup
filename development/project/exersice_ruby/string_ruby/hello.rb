class Hello

  def initialize(hello)
   @hello = hello
  end

  def str_hll
    @hello
  end

  def detail
   "Result => #{self.str_hll}:"
  end

  def output_a
    detail << 'This is my first test.'
  end

  def output_b
    detail << @hello.length.to_s << 'character' 
  end
  
  def output_c
    detail << @hello.reverse 
  end

  def output_d
    detail << @hello.upcase
  end

  def output_e
    detail << @hello.insert(5,'->')
  end

  def output_f
    detail << @hello.delete("o")
  end

  def output_g
     detail << @hello.each_char {|t| print t, ' '}
  end

  def output_h
     detail << @hello.squeeze
  end

  def output_j
    (1..6).each do |n|
     print "#{self.str_hll} #{n}"
    end
  end

  def output_k
    detail << @hello.chop
  end

  def output_l
    detail << @hello.chomp("H")
  end

  def output_m
    detail << @hello.rjust(10)
  end
end
end

