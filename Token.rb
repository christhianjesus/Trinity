$tokens = {
  
  'TkProgram'  => /\Aprogram/,
  'TkUse'  => /\Ause/,
  'TkIn'  => /\Ain/,
  'TkEnd'  => /\Aend/,
  'TkIf'  => /\Aif/,
  'TkThen'  => /\Athen/,
  'TkElse'  => /\Aelse/,
  'TkFor'  => /\Afor/,
  'TkDo'  => /\Ado/,
  'TkWhile'  => /\Awhile/,
  'TkBoolean'  => /\Aboolean/,
  'TkFunction'  => /\Afunction/,
  'TkReturn'  => /\Areturn/,
  'TkBegin'  => /\Abegin/,
  'TkTrue'  => /\Atrue/,
  'TkFalse'  => /\Afalse/,
  'TkRead'  => /\Aread/,
  'TkNumber'  => /\Anumber/,
  'TkMatrix'  => /\Amatrix/,
  'TkCol'  => /\Acol/,
  'TkRow'  => /\Arow/,
  'TkNot'  => /\Anot/,
  'TkPrint'  => /\Aprint/,
  'TkSet'  => /\Aset/,
  'TkPlusCross'  => /\A\.\+\./,
  'TkMinusCross' => /\A\.\-\./,
  'TkMultiplicationCross'  => /\A\.\*\./,
  'TkDivisionCross' => /\A\.\/\./,
  'TkRemainCross'  => /\A\.\%\./,
  'TkDivCross'  => /\A\.div\./,
  'TkModCross'  => /\A\.mod\./,
  'TkPlus'      => /\A\+/,
  'TkMinus'      => /\A\-/,
  'TkMultiplication'      => /\A\*/,
  'TkDivision'   => /\A\//,
  'TkRemain'  => /\A\%/,
  'TkDiv'  => /\Adiv/,
  'TkMod'  => /\Amod/,
  'TkTranspose'  => /\A\'/,
  'TkAnd'      => /\A\&/,
  'TkOr'     => /\A\|/,
  'TkEqual'  => /\A\=\=/,
  'TkNotEqual'  => /\A\/\=/,
  'TkOpenP'  => /\A\(/,
  'TkCloseP'  => /\A\)/,
  'TkGreaterEqual'  => /\A\>\=/,
  'TkLessEqual'  => /\A\<\=/,
  'TkGreater'  => /\A>/,
  'TkLess'  => /\A</,
  'TkOpenBrace'  => /\A\{/,
  'TkCloseBrace'  => /\A\}/,
  'TkComma'  => /\A\,/,
  'TkColon'  => /\A\:/,
  'TkCloseBrack'  => /\A\]/,
  'TkOpenBrack'  => /\A\[/,
  'TkAsig'  => /\A\=/,
  'TkSemicol'  => /\A\;/,
  'TkDigit'   => /\A\-?\d+(\.\d+)?/,
  'TkIdentifier' => /\A[a-zA-Z](\w)*/,
  'TkString' => /\A\"([^\"\\]|\\n|\\\"|\\\\)*\"/
}


class Token
  attr_reader :t, :l, :c
  def initialize(text,line,col)
    @t = text
    @l = line
    @c = col - text.length
  end
  
  def to_s
    "Token: #{self.class}, text:#{@t}, line:#{@l}, col:#{@c}"
  end
  
end

class TkError < Token
  def to_s
    "Error lexico en \"#{@t}\" cerca de la linea \"#{@l}\" y columna \"#{@c}\""
  end
end

$tokens.each do |name,_|
  Object::const_set(name, Class::new(Token))
end