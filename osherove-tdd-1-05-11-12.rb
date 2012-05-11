class StringCalculator
  def add(input)
    Parser.new(input).numbers.reduce(:+)
  end
end

class Parser
  def initialize(input)
    @input = input
  end

  def lines
    @input.sub(%r|^//(.*)|, '').split("\n")
  end

  def list
    res = lines.map {|line| line.split(delimiter) }.flatten
    if res.empty?
      res << "0"
    end
    res
  end

  def numbers
    list.map(&:to_i)
  end

  def delimiter
    matched = @input[%r|^//(.*)|]
    (matched && matched[2]) || ','
  end
end


# After Kata notes
# 
# * Minitest was a better choice.
# * still not certain on how I parsed '' to [0], but I think it belongs to the parser, not the calculator
# * I kept all my tests this time, as opposed to usually refactoring the tests as I go as well
# * Didn't get all the way, but farther than yesterday
# * environmental note: I need to get emacs/sublime setup to run the tests in editor

require 'minitest/autorun'

describe StringCalculator do
  before do
    @it = StringCalculator.new
  end

  it "can be newed up" do
    @it.must_be_instance_of StringCalculator
  end

  it "has a new method" do
    @it.method(:add).wont_be_nil
  end

  it "returns 0 for ''" do
    @it.add("").must_equal 0
  end

  it "returns 1 for '1'" do
    @it.add("1").must_equal 1
  end

  it "returns 2 for '2'" do
    @it.add("2").must_equal 2
  end

  it "returns 3 for '1,2'" do
    @it.add("1,2").must_equal 3
  end

  it "returns 6 for '1,2,3'" do
    @it.add("1,2,3").must_equal 6
  end

  it "returns 6 for '1\n2,3'" do
    @it.add("1\n2,3").must_equal 6
  end
end

describe Parser do
  it "accepts a string input to parse" do
    Parser.new("").must_be_instance_of Parser
  end

  it "parses a list of numbers" do
    Parser.new("1,2").list.must_equal %w[1 2]
  end

  it "parses an empty string" do
    Parser.new("").list.must_equal %w[0]
  end

  it "parses lines" do
    Parser.new("1\n2,3").list.must_equal %w[1 2 3]
  end

  it "splits lines" do
    Parser.new("1\n2,3").lines.must_equal ["1","2,3"]
  end

  it "returns a list of numbers" do
    Parser.new("1,2").numbers.must_equal [1,2]
  end

  it "returns a list of numbers with newlines" do
    Parser.new("1\n2,3").numbers.must_equal [1,2,3]
  end

  it "defaults the delimiter to ','" do
    Parser.new("").delimiter.must_equal ','
  end

  it "changes the delimiter if the first line is '//<new delimiter>'" do
    parser = Parser.new("//;\n")
    parser.delimiter.must_equal ';'
  end
end