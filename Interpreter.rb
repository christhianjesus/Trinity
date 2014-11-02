#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require_relative 'Parser.tab'
require_relative 'Lexer'
#MAIN
def main

  case ARGV.size #si no hay argumento de entrada se le pedirá al usuario un archivo
    when 0
      print "Archivo a interpretar: "
      filename = gets[0..-2]
    when 1 #si hay un argumento de entrada
      filename = ARGV[0]
    else
      puts "USO: #{$0} [archivo]"
      exit -1
  end
  
  begin 
    lexer = Parser::new.parse(Lexer::new(File::read(filename))) #lectura de archivo
  rescue ParseError => e
    puts e
    exit -1
  end
  
end

main
