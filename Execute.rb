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
    atributos.each {|x, y| tablaNew.insert(x.identifier.t); tablaNew.update(x.identifier.t, y)}
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
      else
        nil
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
      @instructions2.each{|e| e.exec(tabla)}   
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


class Set; def exec(tabla); tabla.update(@identifier.t, @expression.exec(tabla)); end; end
    
class Print
  def exec(tabla)
    @printers.each do |x|
      unless x.class == TkString then 
        print(x.exec(tabla))
      else
	x.t[0]=''
        print(x.t.chop.gsub(/\\n/,"\n").gsub(/\\\"/,"\"").gsub( /\\\\/ , "\\" ))
      end
    end
  end
end

class Read
  def exec(tabla)
    valor = tabla.find(@identifier.t)[:valor]
    lectura = STDIN.gets.chomp 
    result = case valor.class.name
    when Fixnum.name then
      unless (/\A\-?\d+(\.\d+)?$/ =~ lectura) != nil
	return Error
      end
      lectura.to_f
    when TrueClass.name
      unless (lectura =='true') or  (lectura =='false') then
	Error
      end
      lectura == 'true'
    when FalseClass.name
      unless (lectura =='true') or  (lectura =='false') then
	Error
      end
      lectura == 'true'
    else
      Error
    end
    tabla.update(@identifier.t,result)   
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
    Matrix.build(@row, @col){|row, col| @exps[row][col].exec(tabla)}
  end
end

class Plus;           def exec(tabla); (@expression1.exec(tabla) + @expression2.exec(tabla)); end; end
  
class Minus;          def exec(tabla); (@expression1.exec(tabla) - @expression2.exec(tabla)); end; end
  
class Multiplication; def exec(tabla); (@expression1.exec(tabla) * @expression2.exec(tabla)); end; end
  
class Division;       def exec(tabla); (@expression1.exec(tabla) / @expression2.exec(tabla)); end; end
  
class Remain;         def exec(tabla); (@expression1.exec(tabla) % @expression2.exec(tabla)); end; end
  
class Div;            def exec(tabla); @expression1.exec(tabla).div(@expression2.exec(tabla)); end; end
  
class Mod;            def exec(tabla); @expression1.exec(tabla).modulo(@expression2.exec(tabla)); end; end


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
      exp1.collect{|e| e.modulo(exp2) }
    else
      exp2.collect{|e| exp1.modulo(e) }
    end
  end
end
  
class Less;         def exec(tabla); return (@expression1.exec(tabla) < @expression2.exec(tabla)); end; end

class Greater;      def exec(tabla); return (@expression1.exec(tabla) > @expression2.exec(tabla)); end; end
  
class LessEqual;    def exec(tabla); return (@expression1.exec(tabla) <= @expression2.exec(tabla)); end; end
  
class GreaterEqual; def exec(tabla); return (@expression1.exec(tabla) >= @expression2.exec(tabla)); end; end
  
class And;          def exec(tabla); return (@expression1.exec(tabla) and @expression2.exec(tabla)); end; end
  
class Or;           def exec(tabla); return (@expression1.exec(tabla) or @expression2.exec(tabla)); end; end 
    
class Equal;        def exec(tabla); (@expression1.exec(tabla) == @expression2.exec(tabla)); end; end 
  
class NotEqual;     def exec(tabla); (@expression1.exec(tabla) != @expression2.exec(tabla)); end; end 
  
class Not;          def exec(tabla); return (!@expression.exec(tabla)); end; end
  
class Uminus;       def exec(tabla); return ((-1) * @expression.exec(tabla)); end; end  
  
class Transpose;    def exec(tabla); return (@tape.exec(tabla)).transpose; end; end
  
class MatrizEval
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
      if matriz.row(0).size == 1 then
        return matriz[exp1-1, 0]
      end
      # Matriz sin un valor y no sea ni row ni col
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

class For
  def exec(tabla)
    tablaNew = ValueTable::new(tabla)
    tablaNew.insert(@identifier.t);
    matriz = @expression.exec(tabla)
    matriz.each do |x|
      tablaNew.update(@identifier.t, x)
      @instructions.each{|y| y.exec(tablaNew)}
    end
  end
end

class Matrix # Inmutable object, bye bye ;)
  def []=(i, j, x)
    @rows[i][j] = x
  end
end

class SetMatriz
  def exec(tabla)
    matriz = tabla.find(@identifier.t)[:valor]
    valor = @expression3.exec(tabla)
    
    exp1 = @expression1.exec(tabla)
    unless @expression2 == [] then
      exp2 = @expression2.exec(tabla)
      matriz[exp1-1, exp2-1] = valor
    else
      if matriz.row_size() == 1 then
        matriz[0, exp1-1] = valor
      end
      if matriz.row(0).size == 1 then
        matriz[exp1-1, 0] = valor
      end
      # Matriz sin un valor y no sea ni row ni col
    end
  end
end
