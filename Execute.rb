require_relative 'AST'
require_relative 'ValueTable'
require 'matrix'

# Redifinicion de las clases del AST con un metodo
# exec, para realizar la ejecucion.

class Program
  def exec()
    tabla = ValueTable::new(nil)
    @functions.each{|e| tabla.insertf(e.identifier.t, e.function)}
    @instructions.each{|e| e.exec(tabla)}
  end
end

class Function
  def exec(tabla, params)
    tablaNew = ValueTable::new(tabla)
    atributos = [@parameters, params].transpose
    atributos.each {|x, y| tablaNew.insert(x.identifier); tablaNew.update(x.identifier, y)}
    @instructions.each do |x|
      v = x.exec(tablaNew)
      print(v)
      return v if x.class == Return
    end
  end
end

class Return
  def exec(tabla)
    @expression.exec(tabla)
  end
end

class Block
  def exec(tabla)
    newTabla = ValueTable::new(tabla)
    @definitions.each{|e| e.exec(newTabla)}  
    @instructions.each{|e| e.exec(newTabla)}
  end
end

class Definition
  def exec(tabla)
    tabla.insert(@identifier.t)
    result = nil
    unless @expression == [] then
      result = @expression.exec(tabla)
    else
      result = case @type.class.name
      when Number.name then
	0
      when Boolean.name then
	false
      when Matriz.name then
	Matrix.zero(@type.row,@type.col)
      end
    end
    tabla.update(@identifier.t, result)
  end
end

class Conditional
  def exec(tabla)
    if @expression.exec(tabla) then
      @instructions1.each{|e| e.exec(tabla)}
    else
      @instructions2.each{|e| e.exec(tabla)} unless @instructions2 == []      
    end
  end
end


class While
  def exec(tabla)
    while @expression.exec(tabla) do
      @instructions.each{|e| e.exec(tabla)}
    end
  end
end


class Set; def exec(tabla); tabla.update(@identifier.t,@expression.exec(tabla)); end; end
    
class Print
  def exec(tabla)
    @printers.map do |x|
      unless x.class == TkString then
	print(x.exec(tabla))
      else
	print(x.t)
      end
    end
  end
end

class Boolean
  def exec(tabla)
    @bool.t == 'true'
  end
end

class Number
  def exec(tabla)
    @number.t.to_f
  end
end

class Matriz
  def exec(tabla)
    Matrix.build(@row,@col){|row, col| @exps[row][col].exec(tabla)}
  end
end

class Plus; def exec(tabla); (@expression1.exec(tabla) + @expression2.exec(tabla)); end; end
  
class Minus; def exec(tabla); (@expression1.exec(tabla) - @expression2.exec(tabla)); end; end
  
class Multiplication; def exec(tabla); (@expression1.exec(tabla) * @expression2.exec(tabla)); end; end
  
class Division; def exec(tabla); (@expression1.exec(tabla) / @expression2.exec(tabla)); end; end
  
class Remain; def exec(tabla); (@expression1.exec(tabla) % @expression2.exec(tabla)); end; end
  
class Div; def exec(tabla); @expression1.exec(tabla).div(@expression2.exec(tabla)); end; end
  
class Mod; def exec(tabla); @expression1.exec(tabla).modulo(@expression2.exec(tabla)).to_i; end; end


class PlusCross
  def exec(tabla)
    exp1 = @expression1.exec(tabla)
    exp2 = @expression2.exec(tabla)
    if exp1.class == Matrix then
      exp1.collect{|e| e + exp2}
    else
      exp2.collect{|e| exp1 + e }
    end  
  end
end
  
class MinusCross
  def exec(tabla)
    exp1 = @expression1.exec(tabla)
    exp2 = @expression2.exec(tabla)
    if exp1.class == Matrix then
      exp1.collect{|e| e - exp2}
    else
      exp2.collect{|e| exp1 - e }
    end   
  end
end

class MultiplicationCross; def exec(tabla); (@expression1.exec(tabla) * @expression2.exec(tabla)); end; end
  
class DivisionCross
  def exec(tabla)
    exp1 = @expression1.exec(tabla)
    exp2 = @expression2.exec(tabla)
    if exp1.class == Matrix then
      exp1.collect{|e| e / exp2}
    else
      exp2.collect{|e| exp1 / e }
    end
  end
end

class RemainCross;
    def exec(tabla)
    exp1 = @expression1.exec(tabla)
    exp2 = @expression2.exec(tabla)
    if exp1.class == Matrix then
      exp1.collect{|e| e % exp2}
    else
      exp2.collect{|e| exp1 % e }
    end
  end
end
  
class DivCross; 
  def exec(tabla)
    exp1 = @expression1.exec(tabla)
    exp2 = @expression2.exec(tabla)
    if exp1.class == Matrix then
      exp1.collect{|e| e.div(exp2)}
    else
      exp2.collect{|e| exp1.div(e) }
    end
  end
end
  
class ModCross
  def exec(tabla)
    exp1 = @expression1.exec(tabla)
    exp2 = @expression2.exec(tabla)
    if exp1.class == Matrix then
      exp1.collect{|e| e.modulo(exp2).to_i}
    else
      exp2.collect{|e| exp1.modulo(e).to_1 }
    end
  end
end
  
class Less; def exec(tabla); return (@expression1.exec(tabla) < @expression2.exec(tabla)); end; end

class Greater; def exec(tabla); return (@expression1.exec(tabla) > @expression2.exec(tabla)); end; end
  
class LessEqual; def exec(tabla); return (@expression1.exec(tabla) <= @expression2.exec(tabla)); end; end
  
class GreaterEqual; def exec(tabla); return (@expression1.exec(tabla) >= @expression2.exec(tabla)); end; end
  
class And; def exec(tabla); return (@expression1.exec(tabla) and @expression2.exec(tabla)); end; end
  
class Or; def exec(tabla); return (@expression1.exec(tabla) or @expression2.exec(tabla)); end; end 
    
class Equal; def exec(tabla); (@expression1.exec(tabla) == @expression2.exec(tabla)); end; end 
  
class NotEqual; def exec(tabla); (@expression1.exec(tabla) != @expression2.exec(tabla)); end; end 
  
class Not; def exec(tabla); return (!@expression.exec(tabla)); end; end
  
class Uminus; def exec(tabla); return (-@expression.exec(tabla)); end; end  
  
class Transpose; def exec(tabla); return (@tape.exec(tabla)).transpose; end; end
  
class MatrizEval  # ERROR 
  def exec(tabla)
    if @expression1.class == Identifier then     
      variable = @expression1.identifier.t
      matriz = tabla.find(variable)[:valor]
    else
      matriz = @expression1.exec(tabla)
    end
    exp1 = @expression2.exec(tabla)
    
    unless @expression3 == [] then
      exp2 = @expression3.exec(tabla)
      return matriz[exp1-1, exp2-1]
    else
      if matriz.row_size() == 1 then
        return matriz[0, exp1-1]
      end
      if matriz.column(0).size == 1 then
        return matriz[exp1-1, 0]
      end
    end
  end
end

class Identifier
  def exec(tabla)
    tabla.find(@identifier.t)[:valor]
  end
end

class Invoke
  def exec(tabla)
    params = []
    @expressions.each{|x| params << x.exec(tabla)}
    tabla.find(@identifier.t)[:valor].exec(tabla, params)
  end
end

  