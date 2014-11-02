# -*- coding: utf-8 -*-
#SymbolicTable
class SymTableError < RuntimeError; end

class RedefineError < SymTableError
  def initialize(token, token_viejo)
    @token = token
    @token_viejo = token_viejo
  end

  def to_s
    "Error en línea #{@token.l}, columna #{@token.c}: la variable '#{@token.t}' fue previamente declarada en la línea #{@token_viejo.l}, columna #{@token_viejo.co}."
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

class SymTable

  def initialize(padre = nil)
    @padre = padre
    @hijos = []
    @table = {}
  end

  def insert(token, tipo)
    raise RedefineError::new(token, find(token.t)[:token]) if isMember?(token.t)
    @table[token.text] = { :token => token, :tipo => tipo}
  end

  def delete(token)
    raise DeleteError::new(token) unless @table.has_key?(token)
    @table.delete(token)
  end

  def find(token)
    return @table[token] if @table.has_key?(token) 
    return nil if @padre.nil?
    return @padre.find(token)
  end

  def isMember?(token)
    return @table.has_key?(token) if @padre.nil?
    return (@table.has_key?(token) or @padre.isMember?(token))
  end
end