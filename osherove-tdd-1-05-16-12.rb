class StringCalculatorError < StandardError
  attr_reader :invalid_values
  def initialize(invalid_values)
    @invalid_values = invalid_values
    super("negatives not allowed: #{invalid_values.join(",")}")
  end
end

class StringCalculator
  attr_writer :parse_source
  def add(str)
    parse(str).reduce(0, :+)
  end

  private
  def parse(str)
    res = parse_source.call(str)
    validate res
  end

  def validate(list)
    unless valid?(list)
      raise StringCalculatorError.new(errors)
    end
    list
  end

  def errors
    @errors
  end

  def valid?(list)
    @errors = list.select {|i| i < 0}
    @errors.empty?
  end

  def parse_source
    @parse_source ||= lambda {|str| Parser.new(str).numbers}
  end
end

class Parser
  attr_reader :input
  def initialize(input)
    @input = input
  end

  def numbers
    res = items.map(&:to_i)
    res.empty? ? [0] : res
  end

  def delimiter
    matched = input.match(%r|//(.*)|)
    (matched && matched.captures[0]) || ','
  end
  
  private
  def lines
    input.sub(%r|//.*|,'').split("\n")
  end

  def items
    lines.map {|line| line.split(delimiter)}.flatten
  end
end

# After Kata notes
#
# * finished on time
# * Having minitest in a guard makes a world of difference
# * Parser feels right. Using MatchData instead of String#[] feels
#   better
# * the private methods on StringCalculator bug me, but the intention
#   was to not add methods to the "public api" that were just helpers
# * I like the flexibility that the dependency injection (thanks to
#   @avdi for the inspiration in Object on Rails) brings to the system.
#   I didn't take full advantage of it in the tests, but not coupling 
#   feels correct
# * using a specialized exception feels right as well (is `raise str`
#   a smell?)

require 'minitest/autorun'

describe StringCalculator do
  before do
    @obj = StringCalculator.new
  end
  it "can be newed up" do
    @obj.wont_be_nil
  end

  it "can add empty string" do
    @obj.add('').must_equal 0
  end

  it "can add single digit" do
    @obj.add('1').must_equal 1
  end

  it "can add two numbers" do
    @obj.add('1,2').must_equal 3
  end

  it "can add three numbers" do
    @obj.add('1,2,3').must_equal 6
  end

  it "can handle newlines" do
    @obj.add("1,2\n3").must_equal 6
  end

  it "parses numbers" do
    called = false
    @obj.parse_source = ->(str) { called = true; [1,2,3] }
    @obj.add("1,2,3")
    called.must_equal true
  end

  it "throws errors if a number is negative" do
    lambda { @obj.add("1,2,-3")}.must_raise StringCalculatorError
  end

  it "includes the error numbers if a number is negative" do
    begin
      @obj.add("1,2,-3,0,-1")
    rescue StringCalculatorError => e
      e.invalid_values.must_equal [-3,-1]
    end
  end
end

describe Parser do
  it "gets inited with a string" do
    Parser.new("").input.wont_be_nil
  end

  it "returns a list of numbers from the string" do
    Parser.new("1,2").numbers.must_equal [1,2]
  end

  it "returns 0 for ''" do
    Parser.new('').numbers.must_equal [0]
  end

  it "returns a list of numbers when newlines are in the string" do
    Parser.new("1,2\n3").numbers.must_equal [1,2,3]
  end

  it "defaults to ',' as a delimiter" do
    Parser.new('').delimiter.must_equal ','
  end

  it "switches delimiter if the first line is '//<new delimiter>" do
    Parser.new("//ab\n1").delimiter.must_equal 'ab'
  end

  it "parses lines with delimiter flag" do
    Parser.new("//ab\n1ab2\n3").numbers.must_equal [1,2,3]
  end
end
