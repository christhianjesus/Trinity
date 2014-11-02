class Error; end

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
    identifier = tabla.find(@identifier.t)
    if identifier.nil? then
      @type = Error
      $ErroresContexto << NoDeclarada::new(@identifier)
    else
      @type = identifier[:tipo]
    end
  end
end


class Additive
  def check(tabla)
    @expression1.check(tabla)
    @expression2.check(tabla)
    unless @expression1.type.eql? @expression2.type and 
      (@expression1.type.eql? Digit or @expression1.type.eql? MatrixExpression) then
      $ErroresContexto << ErrorDeTipo::new(
                                           'SUMA',
                                           @expression1,
                                           @expression2)
    end
    if @expression1.type.eql MatrixExpression then
      unless @expression1.row.eql @expression2.row and @expression1.col.eql @expression2.col
	$ErroresContexto << ErrorDeTamanioMatrices::new(
							'SUMA',
							 @expression1,
							 @expression2)
    @type = @expression1.class
  end
end

class Multiplication
  def check(tabla)
    @expression1.check(tabla)
    @expression2.check(tabla)
    