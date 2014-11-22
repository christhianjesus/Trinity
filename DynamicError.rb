# -*- coding: utf-8 -*-
class DynamicError < RuntimeError
end

class DivisionCero < DynamicError
  def initialize(token)
    print ("Error entre la línea #{token.line} y columna #{token.column}: Intento de división entre cero.")
    exit -1
  end
end

class ErrorLectura < DynamicError
  def initialize(token)
    print ("Error entre la línea #{token.line} y columna #{token.column}: Error de lectura.")
    exit -1
  end
end

class OperacionNoDefinida < DynamicError
  def initialize(token)
    print ("Error entre la línea #{token.line} y columna #{token.column}: Se intento evaluar una matriz con un solo parametro.")
    exit -1
  end
end

class LimiteMatrizInvalido < DynamicError
  def initialize(token)
    print ("Error entre la línea #{token.line} y columna #{token.column}: Se intento evaluar la matriz fuera de sus limites.")
    exit -1
  end
end
