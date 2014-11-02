class True
  def check(tabla)
    @type = self.class
  end
end

class False
  def check(tabla)
    @type = self.class
  end
end

class Digit
  def check(tabla)
    @type = self.class
  end
end

class Identifier
  def check(tabla)
    variable = tabla.find(@attr_value[0][1].text)
    if variable.nil? then
      @type = TipoError
      $ErroresContexto << NoDeclarada::new(@line,
                                           @column,
                                           @attr_value[0][1].text)
    else
      @type = variable[:tipo]
    end
  end
end



class Additive
  def check(tabla)
    @expression1.check(tabla)
    @expression2.check(tabla)
    unless @expression1.class.eql? @expression2.class and 
      (@expression1.class.eql? Digit or @expression1.class.eql? MatrixExpression) then
      $ErroresContexto << ErrorDeTipo::new(@line,
                                           @column,
                                           'SUMA',
                                           @attr_value[0][1].type.name_tk,
                                           @attr_value[1][1].type.name_tk)
    end
    @type = @expression1.class
  end
end