# -*- coding: utf-8 -*-
class ContextError < RuntimeError
end

class ErrorDeTipoUnario < ContextError
  def initialize(exp, clase)
    @linea = exp.line
    @columna = exp.column
    @tipo = exp.type
    @tipoObt = clase
  end

  def to_s
    "Error cerca de la linea #{@linea} y columna #{@columna}: Se esperaba un objeto de tipo #{@tipo.class.name} y se obtuvo #{@tipoObt.class.name}"
  end
end

class NoDeclarada < ContextError
  def initialize(var)
    @linea = var.l
    @columna = var.c
    @nombre = var.t
  end

  def to_s
    "Error cerca de la linea #{@linea} y columna #{@columna}: la variable \"#{@nombre}\" no se encuentra declarada"
  end
end

class NumeroParamInvalidos < ContextError
  def initialize(exp)
    @linea = exp.l
    @columna = exp.c
    @nombre = exp.t
  end
  
  def to_s
    "Error cerca de la linea #{@linea} y columna #{@columna}: distinto numero de parametros en la invocacion de la funcion \"#{@nombre}\""
  end
end

class ErrorMatrixMalFormada < ContextError
  def initialize(exp)
    @linea = exp.line
    @columna = exp.column
  end

  def to_s
    "Error cerca de la linea #{@linea} y columna #{@columna}: Matrix mal formada."
  end
end

class ErrorMatrixMalDefinida < ContextError
  def initialize(token)
    @linea = token.l
    @columna = token.c
  end

  def to_s
    "Error cerca de la linea #{@linea} y columna #{@columna}: Matrix mal definida."
  end
end

class ErrorDeTipo < ContextError
  def initialize(operacion, tipo_izq, tipo_der)
    @linea = tipo_izq.line
    @columna = tipo_izq.column
    @operacion = operacion.name
    @tipo_izq = tipo_izq.type
    @tipo_der = tipo_der.type
  end

  def to_s
    "Error cerca de la linea #{@linea} y columna #{@columna}: Se intenta hacer la operacion #{@operacion} entre operandos de tipos \"#{@tipo_izq}\" y \"#{@tipo_der}\""
  end
end

class ErrorDeTamanioMatrices < ContextError
  def initialize(matrix1, operacion)
    @linea = matrix1.line
    @columna = matrix1.column
    @operacion = operacion.name
  end

  def to_s
    "Error cerca de la linea #{@linea} y columna #{@columna}: El tamanio de las matrices no es consistente con la operacion #{@operacion}."
  end
end

class ErrorMatrixMalLlamada < ContextError
  def initialize(exp)
    @linea = exp.line
    @columna = exp.column
  end

  def to_s
    "Error cerca de la linea #{@linea} y columna #{@columna}: Matrix mal formada."
  end
end

class ErrorDeTipoAsignacion < ContextError
  def initialize(linea, columna, tipo_asig, nombre, tipo_var)
    @linea = linea
    @columna = columna
    @tipo_asig = tipo_asig
    @nombre = nombre
    @tipo_var = tipo_var
  end

  def to_s
    "Error cerca de la linea #{@linea} y columna #{@columna}: se intenta asignar algo del tipo \"#{@tipo_asig}\" a la variable \"#{@nombre}\" de tipo \"#{@tipo_var}\""
  end
end
