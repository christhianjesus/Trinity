class Error; end

def checkInstructions(instructions, tabla)
  if !instructions.empty?
    for instruc in instructions 
      instruc.check(tabla)
    end
  end
end
  
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
      return
    end    
    unless identifier.type.eql? MatrixExpression  then
      @type = Error
      $ErroresContexto << ErrorDeTipo::new(@identifier)
      return
    end
    
    if (/^\d+$/.match(@expression2).nil?) then
      $ErroresContexto << ErrorMatrixMalLlamada::new(@expression1)
      return
    end    
    unless (0 <= @expression2.to_i <= identifier.row) then
      $ErroresContexto << ErrorMatrixMalLlamada::new(@expression1)
      return
    end
    
    case @expression3  
    when nil
      unless (identifier.col.nil?) then
        $ErroresContexto << ErrorMatrixMalLlamada::new(@expression1) 
	return
      end
    when Digit
      if (/^\d+$/.match(@expression3).nil?) then
        $ErroresContexto << ErrorMatrixMalLlamada::new(@expression1)
	return
      end    
      unless (0 <= @expression3.to_i <= identifier.row) then
	$ErroresContexto << ErrorMatrixMalLlamada::new(@expression1)
	return
      end
    else
      $ErroresContexto << ErrorMatrixMalLlamada::new(@expression1)
      return     
    @type = Digit
  end
end

class Conditional
  def check(tabla)
    @expression.check(tabla)
    unless @expression.type.eql? Bool then
      $ErroresContexto << ErrorCondicional::new(@expression)
    end
    checkInstructions(@instructions1,tabla)
    unless @instructions2.nil? then
      checkInstructions(@instructions2,tabla)
    end
  end
end

class While
  def check(tabla)
    @expression.check(tabla)
    unless @expression.type.eql? Bool then
      $ErroresContexto << ErrorCondicional::new(@expression)
    end
    checkInstructions(@instructions, tabla)
    end
  end
end

class For
  def check(tabla)
    identifier = tabla.find(@expression1.t)
    if identifier.nil? then
      @type = Error
      $ErroresContexto << NoDeclarada::new(@identifier)
      return
    end 
    @expression.check(tabla)
    unless @expression.type.eql? MatrixExpression then
      $ErroresContexto << ErrorFor::new(@expression)
      return
    end
    checkInstructions(@instructions, instructions)
    end
  end
end

class Read
  def check(tabla)
    ident = tabla.find(@identifier.t)
    if identifier.nil? then
      @type = Error
      $ErroresContexto << NoDeclarada::new(@identifier)
      return
    end
    @expression.check(tabla)
    
  end
end

class Set
  def check(tabla)
    ident = tabla.find(@identifier.t)
    if ident.nil? then
      @type = Error
      $ErroresContexto << NoDeclarada::new(@identifier)
      return
    end
    @expression.check(tabla)
    unless @expression.type.eql? ident.type then
      $ErroresContexto << ErrorDeTipo::new(self.class,@identifier)
  end
end

class SetMatrix
  def check(tabla)
    ident = tabla.find(@identifier.t)
    if ident.nil? then
      @type = Error
      $ErroresContexto << NoDeclarada::new(@identifier)
      return
    end
    unless @expression.type.eql? MatrixExpression then
      $ErroresContexto << ErrorFor::new(@expression)
      return
    end
    if @expression2.nil? then
      if (indent.row != 1) and (indent.col != 1) then
	$ErroresContexto << ErrorMatrixMalLlamada::new(@expression1)
	return
      end
      if /^\d+$/.match(@expression1).nil? then
        $ErroresContexto << ErrorMatrixMalLlamada::new(@expression1)
        return
      end
    else
      if /^\d+$/.match(@expression1).nil? and /^\d+$/.match(@expression2).nil? then
        $ErroresContexto << ErrorMatrixMalLlamada::new(@expression1)      
      end
    end
    @expression3.check(tabla)
  end
end

class Print
  def check(tabla)
    for expr in @printers do
      if expr.type.eql?  Identifier
	ident = tabla.find(expr.t)
	if ident.nil? then
	  @type = Error
	  $ErroresContexto << NoDeclarada::new(@identifier)
	  return
	end
      else
	unless expr.class.eql? TkString then
	  expr.check(tabla)
	end
      end
    end
  end
end
    
class Block
  def check(tabla)
    
    if !@definitions.empty?
      for definition in @definitions
        tabla.insert(definition.identifier, definition.type)
      end
      rescue RedefineError => r
      $ErroresContexto << r
    end
    checkInstructions(@instructions, tabla)
  end
end

class Program
  tabla = SymTable::new(nil)
  
  checkInstructions(@instructions, tabla)
  
      
      
