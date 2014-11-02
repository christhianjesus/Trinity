class Parser
  token '+' '-' '*' '/' '%' ',' ';' ':' '=' '>' '<' '(' ')' '[' ']'
        '{' '}' '&' '|' '>=' '<=' '==' '/=' '\'' 'div' 'mod' '.+.'
        '.-.' '.*.' './.' '.%.' '.div.' '.mod.' 'do' 'in' 'if' 'end'
        'use' 'for' 'set' 'not' 'row' 'col' 'true' 'then' 'else'
        'read' 'false' 'while' 'begin' 'print' 'digit' 'string'
        'return' 'number' 'matrix' 'program' 'boolean' 'function'
        'identifier' UMINUS

  prechigh
    left     '[' '\''
    right    UMINUS
    left     '*' '/' '%' 'div' 'mod' '.*.' './.' '.%.' '.div.' '.mod.'
    left     '+' '-' '.+.' '.-.'
    right    'not'
    nonassoc '==' '/=' '>=' '<=' '>' '<'
    left     '&'
    left     '|'
  preclow

  convert
    '+'      'TkPlus'
    '-'      'TkMinus'
    '*'      'TkMultiplication'
    '/'      'TkDivision'
    '%'      'TkRemain'
    ','      'TkComma'
    ';'      'TkSemicol'
    ':'      'TkColon'
    '='      'TkAsig'
    '>'      'TkGreater'
    '<'      'TkLess'
    '('      'TkOpenP'
    ')'      'TkCloseP'
    '['      'TkOpenBrack'
    ']'      'TkCloseBrack'
    '{'      'TkOpenBrace'
    '}'      'TkCloseBrace'
    '&'      'TkAnd'
    '|'      'TkOr'
    '>='     'TkGreaterEqual'
    '<='     'TkLessEqual'
    '=='     'TkEqual'
    '/='     'TkNotEqual'
    '\''     'TkTranspose'
    'div'    'TkDiv'
    'mod'    'TkMod'
    '.+.'    'TkPlusCross'
    '.-.'    'TkMinusCross'
    '.*.'    'TkMultiplicationCross'
    './.'    'TkDivisionCross'
    '.%.'    'TkRemainCross'
    '.div.'  'TkDivCross'
    '.mod.'  'TkModCross'
    'do'     'TkDo'
    'in'     'TkIn'
    'if'     'TkIf'
    'end'    'TkEnd'
    'use'    'TkUse'
    'for'    'TkFor'
    'set'    'TkSet'
    'not'    'TkNot'
    'row'    'TkRow'
    'col'    'TkCol'
    'true'   'TkTrue'
    'then'   'TkThen'
    'else'   'TkElse'
    'read'   'TkRead'
    'false'  'TkFalse'
    'while'  'TkWhile'
    'begin'  'TkBegin'
    'print'  'TkPrint'
    'digit'  'TkDigit'
    'string' 'TkString'
    'return' 'TkReturn'
    'number' 'TkNumber'
    'matrix' 'TkMatrix'
    'program' 'TkProgram'
    'boolean' 'TkBoolean'
    'function' 'TkFunction'
    'identifier' 'TkIdentifier'
  end
  
  
  start Program
rule
      Program: Functions 'program' Instructions 'end' ';'     { result = Program::new(val[0], val[2])}
             |           'program' Instructions 'end' ';'     { result = Program::new(    [], val[1])}
             ;
      
      Functions: Functions Function ';'	                   { result = val[0] + [val[1]]}
               |           Function ';'	                   { result =          [val[0]]}
               ;
      
      Function: 'function' 'identifier' '(' Parameters ')' 'return' Type 'begin' Instructions 'end'	{ result = Function::new(val[1], val[3], val[6], val[8])}
              | 'function' 'identifier' '('            ')' 'return' Type 'begin' Instructions 'end' { result = Function::new(val[1],     [], val[5], val[7])}
              ;
      
      Parameters: Parameters ',' Parameter                  { result = val[0] + [val[2]]}
                | Parameter                                 { result =          [val[0]]}
                ;
      
      Parameter: Type 'identifier'                          { result = Parameter::new(val[0], val[1])}
      ;
      
      Type: 'number'                                        { result = Number::new()}
          | 'boolean'                                       { result = Boolean::new()}
          | 'row' '(' 'digit' ')'                           { result = Matrix::new(val[2],[])}     # REVISAR
          | 'col' '(' 'digit' ')'                           { result = Matrix::new([],val[2])}     # REVISAR
          | 'matrix' '(' 'digit' ',' 'digit' ')'            { result = Matrix::new(val[2],val[4])}     # REVISAR
          ;
      
      Instructions: Instructions  Instruction ';'           { result = val[0] + [val[1]]}
                  |                                         { result = []}
                  ;
      
      Instruction:  'use'  Definitions 'in'   Instructions   'end'                               { result = Block::new(val[1],val[3])}
			      | 'if'    Expression 'then' Instructions                     'end' { result = Conditional::new(val[1],val[3],[])}
			      | 'if'    Expression 'then' Instructions 'else' Instructions 'end' { result = Conditional::new(val[1],val[3], val[5])}
			      | 'for' 'identifier' 'in' Expression 'do' Instructions 'end'       { result = For::new(val[1],val[3], val[5])}   
			      | 'while' Expression 'do'   Instructions 'end'                     { result = While::new(val[1],val[3])}
			      | 'print' Printers                                                 { result = Print::new(val[1])}                                                  
			      | 'read'  'identifier'                                                  { result = Read::new(val[1])}
			      | 'set'   'identifier' '=' Expression                                   { result = Set::new(val[1],val[3])}
			      | 'set'   'identifier' '[' Expression ']' '=' Expression                { result = SetMatrix::new(val[1],val[3],[],val[6])}
		              | 'set'   'identifier' '[' Expression ',' Expression ']' '=' Expression { result = SetMatrix::new(val[1],val[3],val[5],val[8])}
			      | Expression                                                            { result = val[0]} 
			      ;

      Definitions: Definitions Definition ';' 	{ result = val[0] + [val[1]]}
                 |             Definition ';'   { result = [val[0]]}
                 ;
      
      Definition: Type 'identifier'                { result = Definition::new(val[0],val[1],[])}
                | Type 'identifier' '=' Expression { result = Definition::new(val[0],val[1],val[3])}
                ;
      
      Printers: Printers ',' Printer { result = val[0] + [val[2]]}
              | Printer              { result =          [val[0]]}
              
      Printer: Expression            { result = val[0]}
             | 'string'              { result = val[0]}

      Expressions: Expressions ',' Expression { result = val[0] + [val[2]]}
                 |                 Expression { result =          [val[0]]}
                 ;
      
      Expression: Expression '+' Expression             { result = Plus::new(val[0], val[2])}
                | Expression '-' Expression 		{ result = Minus::new(val[0], val[2])}
                | Expression '*' Expression 		{ result = Multiplication::new(val[0], val[2])}                                                  
                | Expression '/' Expression 		{ result = Division::new(val[0], val[2])}
                | Expression '%' Expression 		{ result = Remain::new(val[0], val[2])}
                | Expression 'div' Expression 		{ result = Div::new(val[0], val[2])}
                | Expression 'mod' Expression 		{ result = Mod::new(val[0], val[2])}
                | Expression '.+.' Expression 		{ result = PlusCross::new(val[0], val[2])}
                | Expression '.-.' Expression		{ result = MinusCross::new(val[0], val[2])}
                | Expression '.*.' Expression 		{ result = MultiplicationCross::new(val[0], val[2])}                                                  
                | Expression './.' Expression 		{ result = DivisionCross::new(val[0], val[2])}
                | Expression '.%.' Expression 		{ result = RemainCross::new(val[0], val[2])}
                | Expression '.div.' Expression 	{ result = DivCross::new(val[0], val[2])}
                | Expression '.mod.' Expression 	{ result = ModCross::new(val[0], val[2])}                                                  
                | Expression '<' Expression 		{ result = Less::new(val[0], val[2])}
                | Expression '>' Expression 		{ result = Greater::new(val[0], val[2])}

                | Expression '<=' Expression 		{ result = LessEqual::new(val[0], val[2])}
                | Expression '>=' Expression 		{ result = GreaterEqual::new(val[0], val[2])}
                | Expression '==' Expression 		{ result = Equal::new(val[0], val[2])}
                | Expression '/=' Expression 		{ result = NotEqual::new(val[0], val[2])}
                | Expression '&' Expression 		{ result = And::new(val[0], val[2])}
                | Expression '|' Expression 		{ result = Or::new(val[0], val[2])}
                | 'not' Expression                      { result = Not::new(val[1])}
                | '-'   Expression = UMINUS             { result = Uminus::new(Digit::new(val[1]))}
                | Expression '\'' 		        { result = Traspose::new(val[0])}
                | '(' Expression ')'                    { result = val[1]}
                | Expression '[' Expression                ']'   { result = MatrixEval::new(val[0],val[2],[])}                                                 
                | Expression '[' Expression ',' Expression ']'   { result = MatrixEval::new(val[0],val[2],[4])}
                | '{' MatrixExpression '}'                       { result = MatrixExpression::new(val[1])}
                | 'digit' 				         { result = Digit::new(val[0])}
                | 'identifier' 					 { result = Identifier::new(val[0])}
                | 'true'                                         { result = True::new(val[0])}
                | 'false'                                        { result = False::new(val[0])}
                | 'identifier' '(' Expressions ')'               { result = Invoke::new(val[0],val[2])}
                | 'identifier' '('             ')'               { result = Invoke::new(val[0],[])}
                
                ;
                                                        
      MatrixExpression: MatrixExpression ':' Expressions        { result = val[0] + [val[2]]}           #REVISAR
                      | Expressions                             { result = [val[0]]}
                      ;
  
---- header ----

require_relative 'AST'
require_relative 'Lexer'

class SyntacticError < RuntimeError
  attr_reader :token
  def initialize(token)
    @token = token
  end

  def to_s
    unless token
       return " Fatal exception "   
    end
    return "Errorrrr Sintactico del Token '#{@token.t}' en la linea #{@token.l} y columna #{@token.c}."   
  end
end

---- inner ----

    def on_error(id, token, stack)
      raise SyntacticError::new(token)
    end

    def next_token
     token = @lexer.catch
     return [false,false] unless token
     if token.is_a? TkError
          while token
              puts token if token.is_a? TkError
              token = lexer.catch
          end
          exit(-1)
     end
     return [token.class,token]
    end

    def parse(lexer)
      @yydebug = true
      @lexer = lexer
      @tokens = []
      ast = do_parse
      return ast
    end
