#AST

$as_tree = [
            ['AST', [], [
                         ['Program',    %w[functions instructions], []],
                         ['Function',   %w[identifier parameters return type instructions], []],
                         ['Parameter',  %w[type identifier], []],
                         ['Type',        %w[], [
                             ['Boolean',        %w[bool], []],
                             ['Number',         %w[number], []],
                             ['Matriz',         %w[exps row col], []]
                             ]],
                         ['Definition',  %w[type identifier expression], []],
                         ['Instruction', %w[], [
                             ['Block',          %w[definitions instructions], []],
                             ['Conditional',    %w[expression instructions1 instructions2], []],
                             ['For',            %w[identifier expression instructions], []],
                             ['While',          %w[expression instructions], []],
                             ['Print',          %w[printers], []],
                             ['Return',         %w[expression], []],
                             ['Read',           %w[identifier], []],
                             ['Set',            %w[identifier expression], []],
                             ['SetMatriz',      %w[identifier expression1 expression2 expression3], []]
                             ]],
                         ['Expression', %w[], [
                             ['Binary', %w[expression1 expression2], [
                                 ['Additive', %w[], [
                                     ['Plus', %w[], []],
                                     ['Minus', %w[], []],
                                 ]],
                                 ['Multiplication', %w[], []],
                                 ['Divisible', %w[], [
                                     ['Division', %w[], []],
                                     ['Remain', %w[], []],
                                     ['Div', %w[], []],
                                     ['Mod', %w[], []],
                                 ]],
                                 ['ArithmeticCross', %w[], [
                                     ['PlusCross', %w[], []],
                                     ['MinusCross', %w[], []],
                                     ['MultiplicationCross', %w[], []],
                                     ['DivisionCross', %w[], []],
                                     ['RemainCross', %w[], []],
                                     ['DivCross', %w[], []],
                                     ['ModCross', %w[], []],
                                 ]],
                                 ['Logical', %w[], [
                                     ['And', %w[], []],
                                     ['Or', %w[], []],
                                 ]],
                                 ['Comparison', %w[], [
                                     ['Less', %w[], []],
                                     ['Greater', %w[], []],
                                     ['LessEqual', %w[], []],
                                     ['GreaterEqual', %w[], []],
                                 ]],
                                 ['Equality', %w[], [
                                     ['Equal', %w[], []],
                                     ['NotEqual', %w[], []],
                                 ]],
                             ]],
                             ['Unary', %w[expression], [
                                 ['Not', %w[], []],
                                 ['Uminus', %w[], []],
                                 ['Transpose', %w[], []],
                             ]],
                             ['MatrizEval', %w[expression1 expression2 expression3], []],
                             ['Identifier', %w[identifier], []],                
                             ['Invoke', %w[identifier expressions], []]
                            ]]
                 ]]
           ]

def create_class(father, name, attr)

  newClass = Class::new(father) do

    class << self 
      attr_accessor :attr
    end
    
    if !father.eql? Object
      @attr = attr + father.attr
    else
      @attr = attr
    end
    @attr.each { |a| attr_accessor a }
    
    def initialize(*attr)
      attr_value = [self.class.attr, attr].transpose
      attr_value.each do |n, v|
        self.send(n + '=', v)
      end
    end
  end
  Object::const_set(name, newClass)
  return newClass
end

def create_tree(father,tree)
  tree.each do |name|
    n = create_class(father, name[0], name[1])
    create_tree(n, name[2])
  end
end

create_tree(Object,$as_tree)
