$tokens = {
  
  'TkProgram'  => /\Aprogram\s/,
  'TkUse'  => /\Ause\s/,
  'TkIn'  => /\Ain\s/,
  'TkEnd'  => /\Aend/,
  'TkIf'  => /\Aif\s/,
  'TkThen'  => /\Athen\s/,
  'TkElse'  => /\Aelse\s/,
  'TkFor'  => /\Afor\s/,
  'TkDo'  => /\Ado\s/,
  'TkWhile'  => /\Awhile\s/,
  'TkBoolean'  => /\Aboolean\s/,
  'TkFunction'  => /\Afunction\s/,
  'TkReturn'  => /\Areturn/,
  'TkBegin'  => /\Abegin\s/,
  'TkTrue'  => /\Atrue/,
  'TkFalse'  => /\Afalse/,
  'TkRead'  => /\Aread\s/,
  'TkNumber'  => /\Anumber\s/,
  'TkMatriz'  => /\Amatrix/,
  'TkCol'  => /\Acol/,
  'TkRow'  => /\Arow/,
  'TkNot'  => /\Anot/,
  'TkPrint'  => /\Aprint\s/,
  'TkSet'  => /\Aset\s/,
  'TkPlusCross'  => /\A\.\+\./,
  'TkMinusCross' => /\A\.\-\./,
  'TkMultiplicationCross'  => /\A\.\*\./,
  'TkDivisionCross' => /\A\.\/\./,
  'TkRemainCross'  => /\A\.\%\./,
  'TkDivCross'  => /\A\.div\./,
  'TkModCross'  => /\A\.mod\./,
  'TkEqual'  => /\A\=\=/,
  'TkNotEqual'  => /\A\/\=/,
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