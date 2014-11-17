#
# Tabla con los valores de los simbolos.
# -*- coding: utf-8 -*-
#SymbolicTable
class ValueTableError < RuntimeError; end

class RedefineError < SymTableError
  def initialize(variable, valor)
    @variable = variable
    @valor = valor
  end

  def to_s
    "Error: Se intenta asignar el valor #{@valor} a la variable '#{@varible}' declarada como funcion."
  end
end

class ValueTable
  def initialize(padre = nil)
    @padre = padre
    @table = {}
  end

  def insert(variable)
    @table[variable] = {:valor => nil, :funcion => false}
  end
  
  def insertf(variable, funcion)
    @table[variable] = {:valor => funcion, :funcion => true}
  end

  def update(variable, valor)
    raise RedefineError::new(variable, valor) if find(variable)[:funcion]
    find(variable)[:valor] = valor
  end

  def funcion(variable)
    find(variable)[:funcion] = true
  end

  def find(tokent)
    return @table[tokent] if @table.has_key?(tokent)
    return nil if @padre.nil?
    return @padre.find(tokent)
  end
end
