class Error; end

class Bool
  def check(tabla)
    @type = self.class
  end
end

class Digit
  def check(tabla)
    @type = self.class
  end
end

class MatrixExpression
  def check(tabla)
    @expressions.each.map {|exp| exp.check(tabla)}
    @expressions.each.map {|exp| $ErroresContexto << ErrorDeTipo::new(exp) unless exp.type.equal? Digit}
    @expressions.each do |exps|
      n = exps.length if n.nil?
      err = exps.length != n if err.nil? or !err 
    end
    $ErroresContexto << ErrorMatrixMalFormada::new(@expressions.first.first) if err
    @row = @expressions.length
    @col = @expressions.first.length
    @type = self.class
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
  end
end


class Additive
  def check(tabla)
    @expression1.check(tabla)
    @expression2.check(tabla)
    unless @expression1.type.equal? @expression2.type and 
      (@expression1.type.equal? Digit or @expression1.type.equal? MatrixExpression) then
      $ErroresContexto << ErrorDeTipo::new(self.class,@expression1,@expression2)
    end
    unless @expression1.row == @expression2.row and @expression1.col == @expression2.col
      $ErroresContexto << ErrorDeTamanioMatrices::new(@expression1, @expression2)
    end if @expression1.type.eql MatrixExpression            
    @type = @expression1.type
  end
end

class Multiplication
  def check(tabla)
    @expression1.check(tabla)
    @expression2.check(tabla)
    unless @expression1.type.equal? @expression2.type and 
      (@expression1.type.equal? Digit or @expression1.type.equal? MatrixExpression) then
      $ErroresContexto << ErrorDeTipo::new(self.class,@expression1,@expression2)
    end
    unless @expression1.col == @expression2.row
        $ErroresContexto << ErrorDeTamanioMatrices::new(@expression1, @expression2)
    end if @expression1.type.eql MatrixExpression
    @type = @expression1.type
  end
end

class Divisible
  def check(tabla)
    @expression1.check(tabla)
    @expression2.check(tabla)
    unless @expression1.type.equal? Digit and @expression2.type.equal? Digit then    
      $ErroresContexto << ErrorDeTipo::new(self.class,@expression1,@expression2)
    end
    @type = Digit
  end
end

class ArithmeticCross
  def check(tabla)
    @expression1.check(tabla)
    @expression2.check(tabla)
    unless (@expression1.type.equal? Digit and @expression2.type.equal? MatrixExpression) or
	         (@expression2.type.equal? Digit and @expression1.type.equal? MatrixExpression) then    
      $ErroresContexto << ErrorDeTipo::new(self.class,@expression1,@expression2)
    end
    @type = MatrixExpression   
  end
end

class Logical
  def check(tabla)
    @expression1.check(tabla)
    @expression2.check(tabla)

    unless @expression1.type.equal? Bool and @expression2.type.equal? Bool    
      $ErroresContexto << ErrorDeTipo::new(self.class,@expression1,@expression2)
    end
    @type =  @expression1.type
  end
end

class Comparison
  def check(tabla)
    @expression1.check(tabla)
    @expression2.check(tabla)
    unless @expression1.type.equal? Digit and @expression2.type.equal? Digit    
      $ErroresContexto << ErrorDeTipo::new(self.class,@expression1,@expression2)
    end
    @type = Bool
  end
end

class Equality
  def check(tabla)
    @expression1.check(tabla)
    @expression2.check(tabla)
    unless @expression1.type.equal? @expression2.type    
      $ErroresContexto << ErrorDeTipo::new(self.class,@expression1,@expression2)
    end
    @type = Bool
  end
end

class Not
def check(tabla)
    @expression.check(tabla)
    unless @expression.type.equal? Bool
      $ErroresContexto << ErrorDeTipoUnario::new(self.class, @expression)
    end
    @type = Bool
  end
end

class Uminus
def check(tabla)
    @expression.check(tabla)
    unless @expression.type.equal? Digit or @expression.type.equal? MatrixExpression  
      $ErroresContexto << ErrorDeTipo::new(self.class,@expression)
    end
    @type = @expression.type
  end
end

class Transpose
def check(tabla)
    @expression.check(tabla)
    unless @expression.type.equal? MatrixExpression
      $ErroresContexto << ErrorDeTipo::new(self.class, @expression)
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