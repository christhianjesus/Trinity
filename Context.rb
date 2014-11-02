class Error; end

class Bool
  def check(tabla)
    @type = self.class
    @line = @elem.l
    @column = @elem.c
  end
end

class Digit
  def check(tabla)
    @type = self.class
    @line = @digit.l
    @column = @digit.c
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
    @line = @expressions1.line
    @column = @expressions1.column
    if @type = MatrixExpression then
      @row = @expression1.row
      @col = @expression1.col
    end
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
    @line = @expressions1.line
    @column = @expressions1.column
    if @type = MatrixExpression then
      @row = @expression1.row
      @col = @expression2.col
    end
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
    @line = @expressions1.line
    @column = @expressions1.column
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
    @line = @expressions1.line
    @column = @expressions1.column
    @row = @expression1.row
    @col = @expression2.col
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
    @line = @expressions1.line
    @column = @expressions1.column
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
    @line = @expressions1.line
    @column = @expressions1.column
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
    @line = @expressions1.line
    @column = @expressions1.column
  end
end

class Not
def check(tabla)
    @expression.check(tabla)
    unless @expression.type == Bool
      $ErroresContexto << ErrorDeTipoUnario::new(self.class, @expression)
    end
    @type = Bool
    @line = @expressions1.line
    @column = @expressions1.column
    end
end

class Uminus
def check(tabla)
    @expression.check(tabla)
    unless @expression.type == Digit or @expression.type == MatrixExpression  
      $ErroresContexto << ErrorDeTipoUnario::new(self.class, @expression)
    end
    @type = @expression.type
    @line = @expressions.line
    @column = @expressions.column
    if @type = MatrixExpression then
      @row = @expression.row
      @col = @expression.col
    end
  end
end

class Transpose
def check(tabla)
    @expression.check(tabla)
    unless @expression.type == MatrixExpression
      $ErroresContexto << ErrorDeTipoUnario::new(self.class, @expression)
    end
    @type = MatrixExpression
    @line = @expressions.line
    @column = @expressions.column
    if @type = MatrixExpression then
      @row = @expression.row
      @col = @expression.col
    end
  end
end

class MatrixEval
  def check(tabla)
    @expression1.check(tabla)
    @expression2.check(tabla)
    @expression3.check(tabla)
    @type = Digit
    @line = @expression1.line
    @column = @expression1.column
    
    unless @expression1.type == MatrixExpression then
      $ErroresContexto << ErrorDeTipoUnario::new(@expression1, MatrixExpression)
    end
    
    unless @expression2.type == Digit then
      $ErroresContexto << ErrorDeTipoUnario::new(@expression2, Digit)
    end
    
    unless @expression3.nil? or @expression3.type == Digit then
      $ErroresContexto << ErrorDeTipoUnario::new(@expression3, Digit)
    end
  end
end


# Instruccciones

class Conditional
  def check(tabla)
    @expression.check(tabla)
    unless @expression.type == Bool then
      $ErroresContexto << ErrorDeTipoUnario::new(@expression, Bool)
    end
    @instructions1.each.check(tabla)
    @instructions2.each.check(tabla) unless @instructions2.nil?
  end
end

class While
  def check(tabla)
    @expression.check(tabla)
    unless @expression.type == Bool then
      $ErroresContexto << ErrorDeTipoUnario::new(@expression, Bool)
    end
    @instructions.each.check(tabla)
  end
end

class For
  def check(tabla)
    identifier = tabla.find(@identifier.t)
    $ErroresContexto << NoDeclarada::new(@identifier) if identifier.nil?
    unless identifier.nil? or identifier[:tipo] == Digit then
      $ErroresContexto << ErrorDeTipoUnario::new(identifier[:token], Digit)
    end
    @expression.check(tabla)
    unless @expression.type == MatrixExpression then
      $ErroresContexto << ErrorDeTipoUnario::new(@expression, MatrixExpression)
    end
    @instructions.each.check(tabla)
  end
end

class Read
  def check(tabla)
    identifier = tabla.find(@identifier.t)
    $ErroresContexto << NoDeclarada::new(@identifier) if identifier.nil?
    unless identifier.nil? or identifier[:tipo] == Digit or identifier[:tipo] == Bool then
      $ErroresContexto << ErrorDeTipoUnario::new(identifier[:token], Digit)
    end
  end
end

class Set
  def check(tabla)
    identifier = tabla.find(@identifier.t)
    $ErroresContexto << NoDeclarada::new(@identifier) if identifier.nil?
    @expression.check(tabla)
    unless @expression.type == identifier[:tipo] then
      $ErroresContexto << ErrorDeTipoUnario::new(@Expression, identifier[:tipo])
    end
  end
end

class SetMatrix
  def check(tabla)
    identifier = tabla.find(@identifier.t)
    $ErroresContexto << NoDeclarada::new(@identifier) if identifier.nil?
    
    unless identifier.nil? or identifier[:tipo] == MatrixExpression then
      $ErroresContexto << ErrorDeTipoUnario::new(identifier[:token], identifier[:tipo])
    end
    
    @expression1.check(tabla)
    @expression2.check(tabla) unless @expression2.nil?
    @expression3.check(tabla)
    
    unless @expression1.type == Digit then
      $ErroresContexto << ErrorDeTipoUnario::new(@expression2, Digit)
    end
    
    unless @expression2.nil? or @expression3.type == Digit then
      $ErroresContexto << ErrorDeTipoUnario::new(@expression3, Digit)
    end
    
    unless @expression3.type == MatrixExpression then
      $ErroresContexto << ErrorDeTipoUnario::new(@expression3, MatrixExpression)
    end
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
  
      
      
