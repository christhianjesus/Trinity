class Error; end

class Bool
  def check(tabla)
    @type = self.class
    @line = elem.l
    @column = elem.c
  end
end

class Digit
  def check(tabla)
    @type = self.class
    @line = digit.l
    @column = digit.c
  end
end

class Identifier
  def check(tabla)
    identifier = tabla.find(@identifier.t)
    if identifier.nil? then
      @type = Error
      $ErroresContexto << NoDeclarada::new(@identifier)
    else
      @type = identifier[:tipo]
    end
    @line = @identifier.l
    @column = @identifier.c
  end
end

class MatrixExpression
  def check(tabla)
    @expressions.each do |exps|
      n = exps.length if n.nil?
      if err.nil? or !err then
        err = exps.length != n
        $ErroresContexto << ErrorMatrixMalFormada::new(@expressions.first.first) if err # PODRIA DAR ERROR
      end
    end
    @expressions.each.map {|exp| exp.check(tabla); $ErroresContexto << ErrorDeTipoUnario::new(exp, Digit) unless exp.type == Digit}
    @row = @expressions.length
    @col = @expressions.first.lengt 
    @type = self.class

    @line = @expressions.first.first.line
    @column = @expressions.first.first.column
  end
end

class Additive
  def check(tabla)
    @expression1.check(tabla)
    @expression2.check(tabla)
    unless @expression1.type == @expression2.type and 
      (@expression1.type == Digit or @expression1.type == MatrixExpression) then
      $ErroresContexto << ErrorDeTipo::new(self.class, @expression1, @expression2)
    end
    unless @expression1.row == @expression2.row and @expression1.col == @expression2.col
      $ErroresContexto << ErrorDeTamanioMatrices::new(@expression1, self.class)
    end if @expression1.type == MatrixExpression and @expression2.type == MatrixExpression
    @type = @expression1.type
  end
end

class Multiplication
  def check(tabla)
    @expression1.check(tabla)
    @expression2.check(tabla)
    unless @expression1.type == @expression2.type and 
      (@expression1.type == Digit or @expression1.type == MatrixExpression) then
      $ErroresContexto << ErrorDeTipo::new(self.class, @expression1, @expression2)
    end
    unless @expression1.col == @expression2.row
        $ErroresContexto << ErrorDeTamanioMatrices::new(@expression1, self.class)
    end if @expression1.type == MatrixExpression and @expression2.type == MatrixExpression
    @type = @expression1.type
  end
end

class Divisible
  def check(tabla)
    @expression1.check(tabla)
    @expression2.check(tabla)
    unless @expression1.type == Digit and @expression2.type == Digit then    
      $ErroresContexto << ErrorDeTipo::new(self.class, @expression1, @expression2)
    end
    @type = Digit
  end
end

class ArithmeticCross
  def check(tabla)
    @expression1.check(tabla)
    @expression2.check(tabla)
    unless (@expression1.type == Digit and @expression2.type == MatrixExpression) or
	         (@expression2.type == Digit and @expression1.type == MatrixExpression) then    
      $ErroresContexto << ErrorDeTipo::new(self.class, @expression1, @expression2)
    end
    @type = MatrixExpression   
  end
end

class Logical
  def check(tabla)
    @expression1.check(tabla)
    @expression2.check(tabla)
    unless @expression1.type == Bool and @expression2.type == Bool    
      $ErroresContexto << ErrorDeTipo::new(self.class, @expression1, @expression2)
    end
    @type =  Bool
  end
end

class Comparison
  def check(tabla)
    @expression1.check(tabla)
    @expression2.check(tabla)
    unless @expression1.type == Digit and @expression2.type == Digit    
      $ErroresContexto << ErrorDeTipo::new(self.class, @expression1, @expression2)
    end
    @type = Bool
  end
end

class Equality
  def check(tabla)
    @expression1.check(tabla)
    @expression2.check(tabla)
    unless @expression1.type == @expression2.type    
      $ErroresContexto << ErrorDeTipo::new(self.class, @expression1, @expression2)
    end
    @type = Bool
  end
end

class Not
def check(tabla)
    @expression.check(tabla)
    unless @expression.type == Bool
      $ErroresContexto << ErrorDeTipoUnario::new(self.class, @expression)
    end
    @type = Bool
  end
end

class Uminus
def check(tabla)
    @expression.check(tabla)
    unless @expression.type == Digit or @expression.type == MatrixExpression  
      $ErroresContexto << ErrorDeTipoUnario::new(self.class, @expression)
    end
    @type = @expression.type
  end
end

class Transpose
def check(tabla)
    @expression.check(tabla)
    unless @expression.type.equal? MatrixExpression
      $ErroresContexto << ErrorDeTipoUnario::new(self.class, @expression)
    end
    @type = MatrixExpression
  end
end

class MatrixEval
  def check(tabla)
    identifier = tabla.find(@expression1.t)
    
    if identifier.nil? then
      @type = Error
      $ErroresContexto << NoDeclarada::new(@identifier)
    end    
    unless identifier.type.eql? MatrixExpression  then
      @type = Error
      $ErroresContexto << ErrorDeTipo::new(@identifier)
    end
    
    if (/^\d+$/.match(@expression2).nil?) then
      $ErroresContexto << ErrorMatrixMalLlamada::new(@expression1)
    end    
    unless (0 <= @expression2.to_i <= identifier.row) then
      $ErroresContexto << ErrorMatrixMalLlamada::new(@expression1)
    end
    
    case @expression3  
    when nil
      unless (identifier.col.nil?) then
        $ErroresContexto << ErrorMatrixMalLlamada::new(@expression1) 
      end
    when Digit
      if (/^\d+$/.match(@expression3).nil?) then
        $ErroresContexto << ErrorMatrixMalLlamada::new(@expression1)
      end    
      unless (0 <= @expression3.to_i <= identifier.row) then
	$ErroresContexto << ErrorMatrixMalLlamada::new(@expression1)
      end
    else
      $ErroresContexto << ErrorMatrixMalLlamada::new(@expression1)
      
    @type = Digit
  end
end

class Conditional
  def check(tabla)
    @expression.check(tabla)
    unless @expression.type.eql? Bool then
      $ErroresContexto << ErrorCondicionCondicional::new(@line,
                                                         @column,
                                                         @condicion.type.name_tk)
    end
    @instructions1.check(tabla)
    if 
  end
end
