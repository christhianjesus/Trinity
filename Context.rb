require_relative 'AST'
require_relative 'ContextError'
require_relative 'SymTable'

class Error; end
class AST
  attr_accessor :type
end


class Bool < AST
  def check(tabla)
    @type = self.class
    @line = @elem.l
    @column = @elem.c
  end
end

class Digit < AST
  def check(tabla)
    @type = self.class
    @line = @digit.l
    @column = @digit.c
  end
end

class Identifier < AST
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

class MatrixExpression < AST
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

class Additive < AST
  def check(tabla)
    @expression1.check(tabla)
    @expression2.check(tabla)
    unless @expression1.type == @expression2.type and 
      (@expression1.type == Digit or @expression1.type == MatrixExpression) then
      $ErroresContexto << ErrorDeTipo::new(self.class, @expression1, @expression2)
    end
    unless @expression1.row == @expression2.row and @expression1.col == @expression2.col
      $ErroresContexto << ErrorDeTamanioMatrices::new(self.class,@expression1)
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

class Multiplication < AST
  def check(tabla)
    @expression1.check(tabla)
    @expression2.check(tabla)
    unless @expression1.type == @expression2.type and 
      (@expression1.type == Digit or @expression1.type == MatrixExpression) then
      $ErroresContexto << ErrorDeTipo::new(self.class, @expression1, @expression2)
    end
    unless @expression1.col == @expression2.row
        $ErroresContexto << ErrorDeTamanioMatrices::new(self.class, @expression1)
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

class Divisible < AST
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

class ArithmeticCross < AST
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

class Logical < AST
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

class Comparison < AST
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

class Equality < AST
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

class Not < AST
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

class Uminus < AST
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

class Transpose < AST
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

class MatrixEval < AST
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
    @printers.each.check(tabla)
  end
end
    
class Block
  def check(tabla)
    newTabla = SymbolicTable::new(tabla)
    tabla.hijos << newTabla
    @definitions.each.check(newTabla)
    @instructions.each.check(newTabla)
  end
end

class Definition
  def check(table)
    unless @expression.nil? then
      @expression.check(table)
      result = case @type.class
        when Number then Digit
        when Boolean then Bool
        when Matrix then MatrixExpression
      end
      unless @expression.type == result then
        $ErroresContexto << ErrorDeTipoAsignacion::new(@identifier, @type, @expression.type)
      end
    end
    if result == MatrixExpression then
      result.row = @type.row
      result.col = @type.col
    end
    tabla.insert(@identifier, result) 
  end
end

class Program
  def check()
    tabla = SymTable::new(nil)
    @instructions.each.check(tabla)
  end;
end 

class Function
  def check(table)
    
  end
end
