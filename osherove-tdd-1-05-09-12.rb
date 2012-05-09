# TDD Kata from http://osherove.com/tdd-kata-1/
module StringCalculator
  extend self

  DEFAULT_DELIMITER = ","
  def add(str)
    res = split_str(str)
    res = convert_items(res)
    res.inject(0, &:+)
  end

  def parse_delimiter(str)
    delimiter = DEFAULT_DELIMITER
    lines = str.split("\n")
    
    flags = lines.first
    if flags && flags[0..1] == "//"
      delimiter = lines.shift[2..-1]
    end
    return delimiter, lines
  end

  def split_str(str)
    delimiter, lines = parse_delimiter(str)
    lines.map {|line| line.split(delimiter)}.flatten
  end

  def convert_items(arr)
    arr.map(&:to_i)
  end
end

# Notes from after kata
# * Made it to step 4
# * feels ugly.... 
# * the overall system doesn't feel natural, it feels forced
# * procedural, not object oriented
# * no tests for my helper methods. I considered them as 
#   private when I did it, but question that now
# * not obvious from the final result, but lots of churn here
# * inconsistent refactoring of "magic values"
# * 

require 'rubygems'
require 'bacon'

describe "String calculator" do
  it 'has the add method' do
    StringCalculator.method(:add).should.not.equal nil
  end

  it 'does not have 0 arity' do
    StringCalculator.method(:add).arity.should.equal 1
  end

  it 'returns 0 for empty string' do
    StringCalculator.add("").should.equal 0
  end

  it 'returns 1 for "1"' do
    StringCalculator.add("1").should.equal 1
  end

  it 'adds 1 and 2 for "1,2"' do
    StringCalculator.add("1,2").should.equal 3
  end

  it 'adds multiple numbers' do
    StringCalculator.add("1,2,3").should.equal 6
  end

  it 'can handle newline delimiters' do
    StringCalculator.add("1\n2").should.equal 3
  end

  it 'can support new delimiters' do
    StringCalculator.add("//;\n1;2").should.equal 3
  end
end

