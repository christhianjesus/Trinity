require_relative 'AST'
require_relative 'ContextError'
require_relative 'SymbolicTable'
require_relative 'Execute'

class Type
  attr_accessor :line, :column
  
  def == (another)
    result = self.class == another.class
    if result and self.class == Matriz then
      result = (self.row == another.row and self.col == another.col) # JUSTO Y NECESARIO ESE ()
      $ErroresContexto << ErrorDeTamanioMatrices::new(self, self.class) unless result
    end
    return result
  end
  
end

class Error; end

class Boolean < Type
  def type; return self; end
  def check(tabla)
    unless @bool == [] then
      @line = @bool.l
      @column = @bool.c
    end
  end
end

class Number < Type
  def type; return self; end
  def check(tabla)
    unless @number == [] then
      @line = @number.l
      @column = @number.c
    end
  end
end

class Matriz < Type
  def type; return self; end
  def check(tabla)
    if @exps == [] then
      unless @row == [] or  @row.t.match(/\A[1-9]\d*$/) then
        $ErroresContexto << ErrorMatrizMalDefinida::new(@row)
      end
      unless @col == [] or @col.t.match(/\A[1-9]\d*$/) then
        $ErroresContexto << ErrorMatrizMalDefinida::new(@col)
      end
      if @row == [] then
        @row = 1
      else
        @row = @row.t.to_i
      end
      if @col == [] then
        @col = 1
      else
        @col = @col.t.to_i
      end
    else
      n = nil
      err = false
      @exps.each do |exps|
        n = exps.length if n.nil?
        err = n != exps.length unless err
        exps.each {|exp| exp.check(tabla); $ErroresContexto << ErrorDeTipoUnario::new(exp, Number) unless exp.type.class == Number}
      end
      $ErroresContexto << ErrorMatrizMalFormada::new(@exps.first.first) if err
      @row = @exps.length
      @col = @exps.first.length 
      @line = @exps.first.first.line
      @column = @exps.first.first.column
    end
  end
end

#here comes the expressions

class Expression
  attr_accessor :type, :line, :column
end

class Identifier
  def check(tabla)
    identifier = tabla.find(@identifier.t)
    if identifier.nil? then
      @type = Error::new()
      $ErroresContexto << NoDeclarada::new(@identifier)
    else
      @type = identifier[:tipo]
    end
    @line = @identifier.l
    @column = @identifier.c
  end
end


class Additive
  def check(tabla)
    @expression1.check(tabla)
    @expression2.check(tabla)
    unless @expression1.type == @expression2.type and 
	(@expression1.type.class == Number or @expression1.type.class == Matriz) then
      $ErroresContexto << ErrorDeTipo::new(self.class, @expression1, @expression2)
    end
    @type = @expression1.type
    @line = @expression1.line
    @column = @expression1.column
  end
end

class Multiplication
  def check(tabla)
    @expression1.check(tabla)
    @expression2.check(tabla)
    unless @expression1.type.class == @expression2.type.class and 
      (@expression1.type.class == Number or @expression1.type.class == Matriz) then
      $ErroresContexto << ErrorDeTipo::new(self.class, @expression1, @expression2)
    end
    if @expression1.type.class == Matriz and @expression2.type.class == Matriz then
      if @expression1.type.col != @expression2.type.row then
        $ErroresContexto << ErrorDeTamanioMatrices::new(@expression1, self.class)
      end
      @type = Matriz::new([], @expression1.type.row, @expression2.type.col)
    else
      @type = @expression1.type
    end
    @line = @expression1.line
    @column = @expression1.column
  end
end

class Divisible
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
  def check(tabla)
    @expression1.check(tabla)
    @expression2.check(tabla)
    unless (@expression1.type.class == Number and @expression2.type.class == Matriz) or
	         (@expression2.type.class == Number and @expression1.type.class == Matriz) then    
      $ErroresContexto << ErrorDeTipo::new(self.class, @expression1, @expression2)
    end
    if @expression1.type.class == Matriz then
      @type = @expression1.type
    else
      @type = @expression2.type
    end
    @line = @expression1.line
    @column = @expression1.column

  end
end

class Logical
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
  def check(tabla)
    @expression1.check(tabla)
    @expression2.check(tabla)
    unless @expression1.type == @expression2.type
      $ErroresContexto << ErrorDeTipo::new(self.class, @expression1, @expression2)
    end
    @type = Boolean::new([])
    @line = @expression1.line
    @column = @expression1.column
  end
end

class Not
  def check(tabla) 
    @expression.check(tabla)
    unless @expression.type.class == Boolean
      $ErroresContexto << ErrorDeTipoUnario::new(Boolean::new([]), @expression)
    end
    @type = Boolean::new([])
    @line = @expression.line
    @column = @expression.column
  end
end

class Uminus
  def check(tabla)
    @expression.check(tabla)
    unless @expression.type.class == Number or @expression.type.class == Matriz  
      $ErroresContexto << ErrorDeTipoUnario::new(Number::new([]), @expression.type)
    end
    @type = @expression.type
    @line = @expression.line
    @column = @expression.column
  end
end

class Transpose
  def check(tabla)
    @expression.check(tabla)
    unless @expression.type.class == Matriz
      $ErroresContexto << ErrorDeTipoUnario::new(Matriz::new([],[],[]), @expression)
    end
    @type = Matriz::new([], @expression.type.col, @expression.type.row)
    @line = @expression.line
    @column = @expression.column
  end
end

class MatrizEval
  def check(tabla)
    @expression1.check(tabla)
    @expression2.check(tabla)
    @expression3.check(tabla) unless  @expression3 == []
    @type = Number::new([])
    @line = @expression1.line
    @column = @expression1.column
    
    unless @expression1.type.class == Matriz then
      $ErroresContexto << ErrorDeTipoUnario::new(@expression1, Matriz)
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
  def check(tabla)
    
    identifier = tabla.find(@identifier.t)
    $ErroresContexto << NoDeclarada::new(@identifier) if identifier.nil?
    if @expressions.length == identifier[:parametro].length then
      badthings = [@expressions, identifier[:parametro]].transpose
      badthings.each {|x, y| x.check(tabla);
        $ErroresContexto << ErrorDeTipoUnario::new(y, x) unless x.type == y.type} unless @expressions.nil?
    else
      $ErroresContexto << NumeroParamInvalidos::new(@identifier)
    end unless identifier.nil?
    unless identifier.nil? then
      @type = identifier[:tipo]
    else
      @type = Error::new()
    end
    @line = @identifier.l
    @column = @identifier.c
  end
end

# Instruccciones

class Conditional
  def check(tabla)
    @expression.check(tabla)
    unless @expression.type.class == Boolean then
      $ErroresContexto << ErrorDeTipoUnario::new(@expression, Boolean)
    end
    @instructions1.each {|x| x.check(tabla) }
    @instructions2.each {|x| x.check(tabla) } unless @instructions2.nil?
  end
end

class While
  def check(tabla)
    @expression.check(tabla)
    unless @expression.type.class == Boolean then
      $ErroresContexto << ErrorDeTipoUnario::new(@expression, Boolean)
    end
    @instructions.each {|x| x.check(tabla) }
  end
end

class For
  def check(tabla)
    newTabla = SymbolicTable::new(tabla)
    tabla.hijos << newTabla
    @expression.check(tabla)
    unless @expression.type.class == Matriz then
      $ErroresContexto << ErrorDeTipoUnario::new(@expression, Matriz)
    end
    newTabla.insert(@identifier, Number::new([])) 
    @instructions.each {|x| x.check(newTabla) }
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
    unless @expression.type == identifier[:tipo] then
      $ErroresContexto << ErrorDeTipoUnario::new(@expression, identifier[:tipo])
    end
  end
end

class SetMatriz
  def check(tabla)
    identifier = tabla.find(@identifier.t)
    $ErroresContexto << NoDeclarada::new(@identifier) if identifier.nil?
    
    unless identifier.nil? or identifier[:tipo].class == Matriz then
      $ErroresContexto << ErrorDeTipoUnario::new(identifier[:token], identifier[:tipo].class)
    end
    
    @expression1.check(tabla)
    @expression2.check(tabla) unless @expression2 == []
    @expression3.check(tabla)
    
    unless @expression1.type.class == Number then
      $ErroresContexto << ErrorDeTipoUnario::new(@expression2, Number)
    end

    unless @expression2 == [] or @expression2.type.class == Number then
      $ErroresContexto << ErrorDeTipoUnario::new(@expression2, Number)
    end
    
    unless @expression3.type.class == Number then
      $ErroresContexto << ErrorDeTipoUnario::new(@expression3, Number)
    end
  end
end

class Return
  def check(tabla)
    identifier = tabla.find('return')
    @expression.check(tabla)
    unless @expression.type == identifier[:tipo] then
      $ErroresContexto << ErrorDeTipoUnario::new(@expression, identifier[:tipo])
    end
  end
end

class Print
  def check(tabla)
    @printers.each {|x| x.check(tabla) unless x.class == TkString}
  end
end
    
class Block
  def check(tabla)
    newTabla = SymbolicTable::new(tabla)
    tabla.hijos << newTabla
    @definitions.each {|x| x.check(newTabla) }
    @instructions.each {|x| x.check(newTabla) }
  end
end

class Definition
  def check(table)
    @type.check(table)
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
    @functions.each {|x| x.check(tabla) }
    @instructions.each {|x| x.check(tabla) }
    
  end
end 

class Parameter
  def check(tabla)
    @type.check(tabla)
    tabla.insert(@identifier, @type)
  end
end

class Function
  def function; return self; end
  def check(tabla)
    tablaNew = SymbolicTable::new(nil)
    params = []
    tabla.hijos << tablaNew
    @type.check(tabla)
    tablaNew.insert(@return, @type)
    @parameters.each {|x| x.check(tablaNew); params << x.type}
    tabla.insertF(@identifier, @type, params)
    tablaNew.insertF(@identifier, @type, params) unless tablaNew.isMember?(@identifier.t)
    @instructions.each {|x| x.check(tablaNew) }
  end
end