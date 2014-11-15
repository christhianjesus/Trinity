# -*- coding: utf-8 -*-
#SymbolicTable
class SymTableError < RuntimeError; end

class RedefineError < SymTableError
  def initialize(token, token_viejo)
    @token = token
    @token_viejo = token_viejo
  end

  def to_s
    "Error en lnea #{@token.l}, columna #{@token.c}: la variable '#{@token.t}' fue previamente declarada en la lnea #{@token_viejo.l}, columna #{@token_viejo.co}."
  end
end

class DeleteError < SymTableError
  def initialize(token)
    @token = token
  end

  def to_s
    "Error no se puede eliminar el token '#{@token.t}'"
  end
end

class SymbolicTable
  attr_accessor :hijos
  def initialize(padre = nil)
    @padre = padre
    @hijos = []
    @table = {}
  end

  def insert(token, tipo)
    raise RedefineError::new(token, @table[token.t][:token]) if @table.has_key?(token.t)
    @table[token.t] = { :token => token, :tipo => tipo}
  end

  def delete(tokent)
    raise DeleteError::new(tokent) unless @table.has_key?(tokent)
    @table.delete(tokent)
  end

  def find(tokent)
    return @table[tokent] if @table.has_key?(tokent) 
    return nil if @padre.nil?
    return @padre.find(tokent)
  end

  def isMember?(tokent)
    return @table.has_key?(tokent)
  end
end