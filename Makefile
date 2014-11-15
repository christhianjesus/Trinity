all: entrega1
entrega1:
	 racc Parser.y
	rm -f Trinity 
	ln -s Interpreter.rb Trinity


