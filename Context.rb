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
    unless @expression1.type.eql? @expression2.type and 
      (@expression1.type.eql? Digit or @expression1.type.eql? MatrixExpression) then
      $ErroresContexto << ErrorDeTipo::new(@line,
                                           @column,
                                           'SUM',
                                           @expression1,
                                           @expression2)
    end
    if @expression1.type.eql MatrixExpression then
      unless @expression1.row.eql @expression2.row and @expression1.col.eql @expression2.col
	$ErroresContexto << ErrorDeTamanioMatrices::new(@line,
                                                        @column,
							'SUM',
							 @expression1,
			                                 @expression2)
      end
    end						 
    @type = @expression1.type
  end
end

class Multiplication
  def check(tabla)
    @expression1.check(tabla)
    @expression2.check(tabla)
    unless @expression1.type.eql? @expression2.type and 
      (@expression1.type.eql? Digit or @expression1.type.eql? MatrixExpression) then
      
      $ErroresContexto << ErrorDeTipo::new(@line,
                                           @column,
                                           'MULTIPLICATION',
                                           @expression1,
                                           @expression2)
    end
    if @expression1.type.eql MatrixExpression then
      unless @expression1.col.eql @expression2.row
	$ErroresContexto << ErrorDeTamanioMatrices::new(@line,
                                                        @column,
							'MULTIPLICATION',
							@expression1,
                                                        @expression2)
      end
     end 
    @type = @expression1.type   
  end
end

class Divisible
  def check(tabla)
    @expression1.check(tabla)
    @expression2.check(tabla)
    unless @expression1.type.eql? @expression2.type and @expression1.type.eql? Digit then    
      $ErroresContexto << ErrorDeTipo::new(@line,
                                           @column,
                                           'DIVISION',
                                           @expression1,
                                           @expression2)
    end
  @type = @expression1.type   
  end
end


    