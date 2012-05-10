# TDD Kata from http://osherove.com/tdd-kata-1/
class Parser
  def initialize(input)
    @input = input
  end

  def numbers
    parsed_list.map(&:to_i)
  end

  def parsed_list
    lines.map {|line| line.split(',') }.flatten
  end

  def lines
    @input.split('\n')
  end
end

class StringCalculator
  def add(input)
    numbers = Parser.new(input).numbers
    numbers.reduce(0, :+)
  end
end

# After Kata notes
#
# * I got stuck trying to figure out the best way to split the
#   responsibility of splitting by commas and splitting by newlines
# * I also was slowed down figuring out the best way to TDD the 
#   existance of the classes, and remembering Bacon. Switching to 
#   MiniTest::Spec might help here
# * The overall feel of this is way better to me. Not as ugly, not 
#   tugging at me (for the most part)
# * One of the few places that does bug me is related to the commented
#   out test below. I don't feel that the responsibility of add('') => 0 
#   falls to the add method, but I wasn't happy with the parsing code if 
#   I pushed it to the Parser (due to conditionals)
# * Thinking in nouns really helped with naming and identifying my methods

require 'rubygems'
require 'bacon'

describe 'StringCalculator' do
  before do
    @obj = StringCalculator.new
  end

  it "returns 0 for ''" do
    @obj.add('').should.equal 0
  end

  it "returns 1 for '1'" do
    @obj.add('1').should.equal 1
  end

  it "adds 1 and 2 for '1,2'" do
    @obj.add('1,2').should.equal 3
  end

  it "adds 1,2 and 3 for '1,2,3'" do
    @obj.add('1,2,3').should.equal 6
  end
  
  it "adds 1,2 and 3 for '1,2\n3'" do
    @obj.add('1,2\n3').should.equal 6
  end
end

describe 'Parser' do
  it 'takes input' do
    should.not.raise { Parser.new('') }
  end

  it 'converts single numbers in the input to ints' do
    Parser.new('1').numbers.should.equal [1]
  end

#  it 'converts empty string to 0' do
#    Parser.new('').numbers.should.equal [0]
#  end

  it 'splits comma separated numbers' do 
    Parser.new('1,2').numbers.should.equal [1,2]
  end

  it 'can split on newlines' do
    Parser.new('1\n2,3').numbers.should.equal [1,2,3]
  end
end
