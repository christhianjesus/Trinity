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

class ArithmeticCross
  def check(tabla)
    @expression1.check(tabla)
    @expression2.check(tabla)
    unless (@expression1.type.eql? Digit and @expression2.type.eql? MatrixExpression) or
	   (@expression2.type.eql? Digit and @expression1.type.eql? MatrixExpression) then    
      $ErroresContexto << ErrorDeTipo::new(@line,
                                           @column,
                                           'CROSS OPERATION',
                                           @expression1,
                                           @expression2)
    end
  @type = MatrixExpression   
  end
end

class Logical
  def check(tabla)
    @expression1.check(tabla)
    @expression2.check(tabla)
    unless @expression1.type.eql? Bool and @expression2.type.eql? Bool    
      $ErroresContexto << ErrorDeTipo::new(@line,
                                           @column,
                                           'LOGICAL OPERATION',
                                           @expression1,
                                           @expression2)
    end
  @type =  @expression1.type
  end
end

class Comparison
  def check(tabla)
    @expression1.check(tabla)
    @expression2.check(tabla)
    unless @expression1.type.eql? Digit and @expression2.type.eql? Digit    
      $ErroresContexto << ErrorDeTipo::new(@line,
                                           @column,
                                           'COMPARISON OPERATION',
                                           @expression1,
                                           @expression2)
    end
  @type = Bool
  end
end

class Equality
  def check(tabla)
    @expression1.check(tabla)
    @expression2.check(tabla)
    unless @expression1.type.eql? @expression2.type    
      $ErroresContexto << ErrorDeTipo::new(@line,
                                           @column,
                                           'EQUALTY OPERATION',
                                           @expression1,
                                           @expression2)
    end
  @type = Bool
  end
end

class Not
def check(tabla)
    @expression.check(tabla)
    unless @expression.type.eql? Bool   
      $ErroresContexto << ErrorDeTipoUnario::new(@line,
                                                 @column,
                                                 'NEGATION',
                                                 @expression)
    end
  @type = Bool
  end
end

class Uminus
def check(tabla)
    @expression.check(tabla)
    unless (@expression.type.eql? Digit) or (@expression.type.eql? MatrixExpression)  
      $ErroresContexto << ErrorDeTipo::new(@line,
                                           @column,
                                           'UMINUS',
                                           @expression)
    end
  @type = @expression.type
  end
end

class Transpose
def check(tabla)
    @expression.check(tabla)
    unless @expression.type.eql? MatrixExpression
      $ErroresContexto << ErrorDeTipo::new(@line,
                                           @column,
                                           'UMINUS',
                                           @expression)
    end
  @type = @expression.type
  end
end