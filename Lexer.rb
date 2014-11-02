require_relative 'Token'

class Lexer
  
  def initialize(input)
    @input = input
    @tokens = []
    @line  = 1
    @col   = 1
  end

  def skip(num)
    return if num.eql?0
    
    skiped = @input[0,num]
    @input = @input[num..-1]
    @line += skiped.count("\n")
    
    #array  = skiped.scan(/\s */).map{|x| x.delete("\n")}
    
    if skiped.count("\n").eql?0
      @col += num
    else
      @col = num - skiped.rindex("\n")
    end
  end

  def catch
    
    /\A(\#.*|\s)*/ =~ @input
    self.skip($&.length)
    return nil if @input.empty?
    
    if $tokens.detect{|k,v| v =~ @input && @x = k}
      self.skip($&.length)
      tknClass = Object::const_get(@x)
    else
      @input =~ /\A./
      self.skip(1)
      tknClass = TkError
    end
    
    @tokens << tknClass.new($&,@line,@col)
    return @tokens.last
  end

  def out
    @tokens.each{|t| puts t}
  end
end
