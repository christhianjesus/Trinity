
require_relative 'AST'
require_relative 'ContextError'
require_relative 'SymbolicTable'

class Error; end

class Matrix
  attr_accessor :type, :line, :column
  def check(tabla)
    if @row.is_a? Integer then
      print("Integer")
    end
    if @row.is_a? String then
      print("Integer")
    end
  end
end     

class Boolean
  attr_accessor :type, :line, :column
  def check(tabla)
    @line = @bool.l
    @column = @bool.c
    @type = Boolean::new(@bool)
  end
end

class Number
  attr_accessor :type, :line, :column
  def check(tabla)
    @line = @number.l
    @column = @number.c
    @type = Number::new(@number)
  end
end

class Identifier
  attr_accessor :type, :line, :column
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
  attr_accessor :type, :line, :column
  def check(tabla)
    err = false
    n= nil
    @expressions.each do |exps|
      n = exps.length if n.nil?
      if err.nil? or !err then
        err = exps.length != n
        $ErroresContexto << ErrorMatrixMalFormada::new(@expressions.first.first) if err # PODRIA DAR ERROR
	exit -1 if err
      end
      exps.map {|exp| exp.check(tabla); $ErroresContexto << ErrorDeTipoUnario::new(exp, Number) unless exp.type.class == Number}
    end
    row = @expressions.length
    col = @expressions.first.length 
    @type = Matrix::new(row, col)

    @line = @expressions.first.first.line
    @column = @expressions.first.first.column
  end
end

class Additive
  attr_accessor :type, :line, :column
  def check(tabla)
    @expression1.check(tabla)
    @expression2.check(tabla)
    unless @expression1.type.class == @expression2.type.class and 
      (@expression1.type.class == Number or @expression1.type.class == Matrix) then
      $ErroresContexto << ErrorDeTipo::new(self.class, @expression1, @expression2)
    end
    unless @expression1.type.row == @expression2.type.row and @expression1.type.col == @expression2.type.col
      $ErroresContexto << ErrorDeTamanioMatrices::new(self.class, @expression1)
    end if @expression1.type.class == Matrix and @expression2.type.class == Matrix
    @type = @expression1.type #Cambiar 4ta
    @line = @expression1.line
    @column = @expression1.column
  end
end

class Multiplication
  attr_accessor :type, :line, :column
  def check(tabla)
    @expression1.check(tabla)
    @expression2.check(tabla)
    unless @expression1.type.class == @expression2.type.class and 
      (@expression1.type.class == Number or @expression1.type.class == Matrix) then
      $ErroresContexto << ErrorDeTipo::new(self.class, @expression1, @expression2)
    end
    unless @expression1.type.col == @expression2.type.row
        $ErroresContexto << ErrorDeTamanioMatrices::new(self.class, @expression1)
    end if @expression1.type.class == Matrix and @expression2.type.class == Matrix
    if @expression1.type.class == Matrix and @expression2.type.class == Matrix then
      @type = Matrix::new(@expression1.type.row, @expression2.type.col)
    else
      @type = @expression1.type
    end
    @line = @expression1.line
    @column = @expression1.column
  end
end

class Divisible
  attr_accessor :type, :line, :column
  def check(tabla)
    @expression1.check(tabla)
    @expression2.check(tabla)
    unless @expression1.type.class == Number and @expression2.type.class == Number then    
      $ErroresContexto << ErrorDeTipo::new(self.class, @expression1, @expression2)
    end
    @type = @expression1.type
    @line = @expression1.line
    @column = @expression1.column
  end
end

class ArithmeticCross
  attr_accessor :type, :line, :column
  def check(tabla)
    @expression1.check(tabla)
    @expression2.check(tabla)
    unless (@expression1.type.class == Number and @expression2.type.class == Matrix) or
	         (@expression2.type.class == Number and @expression1.type.class == Matrix) then    
      $ErroresContexto << ErrorDeTipo::new(self.class, @expression1, @expression2)
    end
    if @expression1.type.class == Matrix then
      @type = @expression1.type
    else
      @type = @expression2.type
    end
    @line = @expression1.line
    @column = @expression1.column
  end
end

class Logical
  attr_accessor :type, :line, :column
  def check(tabla)
    @expression1.check(tabla)
    @expression2.check(tabla)
    unless @expression1.type.class == Boolean and @expression2.type.class == Boolean 
      $ErroresContexto << ErrorDeTipo::new(self.class, @expression1, @expression2)
    end
    @type = Boolean::new([])
    @line = @expression1.line
    @column = @expression1.column
  end
end

class Comparison
  attr_accessor :type, :line, :column
  def check(tabla)
    @expression1.check(tabla)
    @expression2.check(tabla)
    unless @expression1.type.class == Number and @expression2.type.class == Number    
      $ErroresContexto << ErrorDeTipo::new(self.class, @expression1, @expression2)
    end
    @type = Boolean::new([])
    @line = @expression1.line
    @column = @expression1.column
  end
end

class Equality
  attr_accessor :type, :line, :column
  def check(tabla)
    @expression1.check(tabla)
    @expression2.check(tabla)
    unless @expression1.type.class == @expression2.type.class    
      $ErroresContexto << ErrorDeTipo::new(self.class, @expression1, @expression2)
    end
    @type = Boolean::new([])
    @line = @expression1.line
    @column = @expression1.column
  end
end

class Not
  attr_accessor :type, :line, :column
  def check(tabla) 
    @expression.check(tabla)
    unless @expression.type.class == Boolean
      $ErroresContexto << ErrorDeTipoUnario::new(self.class, @expression)
    end
    @type = @expression.type
    @line = @expression.line
    @column = @expression.column
  end
end

class Uminus
  attr_accessor :type, :line, :column
  def check(tabla)
    @expression.check(tabla)
    unless @expression.type.class == Number or @expression.type.class == Matrix  
      $ErroresContexto << ErrorDeTipoUnario::new(self.class, @expression)
    end
    @type = @expression.type
    @line = @expression.line
    @column = @expression.column
  end
end

class Transpose
  attr_accessor :type, :line, :column
  def check(tabla)
    @expression.check(tabla)
    unless @expression.type.class == Matrix
      $ErroresContexto << ErrorDeTipoUnario::new(self.class, @expression)
    end
    @type = Matrix::new(@expression.type.col, @expression.type.row)
    @line = @expression.line
    @column = @expression.column
  end
end

class MatrixEval
  attr_accessor :type, :line, :column
  def check(tabla)
    @expression1.check(tabla)
    @expression2.check(tabla)
    @expression3.check(tabla) unless  @expression3 == []
    @type = Number::new([])
    @line = @expression1.line
    @column = @expression1.column
    
    unless @expression1.type.class == Matrix then
      $ErroresContexto << ErrorDeTipoUnario::new(@expression1, Matrix)
    end
    
    unless @expression2.type.class == Number then
      $ErroresContexto << ErrorDeTipoUnario::new(@expression2, Number)
    end
    
    unless @expression3 == [] or @expression3.type.class == Number then
      $ErroresContexto << ErrorDeTipoUnario::new(@expression3, Number)
    end
  end
end

class Invoke
  attr_accessor :type, :line, :column
  def check(tabla)
    @expressions.map {|x| x.check(tabla) } unless @expressions.nil?
    
    identifier = tabla.find(@identifier.t)
    $ErroresContexto << NoDeclarada::new(@identifier) if identifier.nil?

    
  end
end

# Instruccciones

class Conditional
  def check(tabla)
    @expression.check(tabla)
    unless @expression.type.class == Boolean then
      $ErroresContexto << ErrorDeTipoUnario::new(@expression, Boolean)
    end
    @instructions1.map {|x| x.check(tabla) }
    @instructions2.map {|x| x.check(tabla) } unless @instructions2.nil?
  end
end

class While
  def check(tabla)
    @expression.check(tabla)
    unless @expression.type.class == Boolean then
      $ErroresContexto << ErrorDeTipoUnario::new(@expression, Boolean)
    end
    @instructions.map {|x| x.check(tabla) }
  end
end

class For
  def check(tabla)
    newTabla = SymbolicTable::new(tabla)
    tabla.hijos << newTabla
    @expression.check(tabla)
    unless @expression.type.class == Matrix then
      $ErroresContexto << ErrorDeTipoUnario::new(@expression, Matrix)
    end
    newTabla.insert(@identifier, Number::new([])) 
    @instructions.map {|x| x.check(newTabla) }
  end
end

class Read
  def check(tabla)
    identifier = tabla.find(@identifier.t)
    $ErroresContexto << NoDeclarada::new(@identifier) if identifier.nil?
    unless identifier.nil? or identifier[:tipo].class == Number or identifier[:tipo].class == Boolean then
      $ErroresContexto << ErrorDeTipoUnario::new(identifier[:token], Number)
    end
  end
end

class Set
  def check(tabla)
    identifier = tabla.find(@identifier.t)
    $ErroresContexto << NoDeclarada::new(@identifier) if identifier.nil?
    @expression.check(tabla)
    unless @expression.type.class == identifier[:tipo].class then
      $ErroresContexto << ErrorDeTipoUnario::new(@Expression, identifier[:tipo].class)
    end
  end
end

class SetMatrix
  def check(tabla)
    identifier = tabla.find(@identifier.t)
    $ErroresContexto << NoDeclarada::new(@identifier) if identifier.nil?
    
    unless identifier.nil? or identifier[:tipo].class == Matrix then
      $ErroresContexto << ErrorDeTipoUnario::new(identifier[:token], identifier[:tipo].class)
    end
    
    @expression1.check(tabla)
    @expression2.check(tabla) unless @expression2 == []
    @expression3.check(tabla)
    
    unless @expression1.type.class == Number then
      $ErroresContexto << ErrorDeTipoUnario::new( Number, @expression2)
    end
    
    unless @expression2 == [] or @expression3.type.class == Number then
      $ErroresContexto << ErrorDeTipoUnario::new( Number, @expression3)
    end
    
    unless @expression3.type.class == Number then
      $ErroresContexto << ErrorDeTipoUnario::new(Number, @expression3)
    end
  end
end



class Print
  def check(tabla)
    @printers.map {|x| x.check(tabla) unless x.class == TkString}
  end
end
    
class Block
  def check(tabla)
    newTabla = SymbolicTable::new(tabla)
    tabla.hijos << newTabla
    @definitions.map {|x| x.check(newTabla) }
    @instructions.map {|x| x.check(newTabla) }
  end
end

class Definition
  def check(table)
    table.insert(@identifier, @type) 
    
    unless @expression == [] then
      @expression.check(table)
      unless @expression.type == @type then
        $ErroresContexto << ErrorDeTipoAsignacion::new(@identifier, @type, @expression.type)
      end
    end
  end
end

class Program
  def check()
    tabla = SymbolicTable::new(nil)
    @instructions.map {|x| x.check(tabla) }
  end
end 

class Parameter
  def check(tabla)
    tabla.insert(@identifier, @type) 
  end
end

class Function
  def check(tabla)
    tablaNew = SymbolicTable::new(nil)
    tabla.hijos << tablaNew
    @parameters.map {|x| x.check(tablaNew) }
    @instructions.map {|x| x.check(tablaNew) }
    tablaNew.insert(@identifier, @type)
  end
end