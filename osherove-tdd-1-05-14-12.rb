class StringCalculator
  def self.add(input)
    new(input).add
  end

  def initialize(input)
    @input = input
  end

  def add
    if valid?
      numbers.reduce(0,:+)
    else
      raise "negatives not allowed: #{errors.join(",")}"
    end
  end

  def numbers
    lines.map {|line| line.split(delimiter)}.flatten.map(&:to_i)
  end

  def lines
    @input.sub(%r|//(.*)|, '').split("\n")
  end

  def delimiter
    matched = @input[%r|//(.*)|]
    (matched && $1) || ','
  end

  def valid? 
    numbers.all? {|n| n >= 0 }
  end

  def errors
    numbers.select {|n| n < 0}
  end
end

# After kata notes
#
# * took a few minutes extra, but completed the base kata in 35 minutes
# * decided to not include the parser this time... not certain I like 
#   it. I think if i had more time I would refactor to the parser again
# * I don't like using $1 type variables, but it worked well here
# * nice benefit to doing TDD test first: I mistakenly speced 
#   `StringCalculator.new('1,2').must_equal 1` at one point, and the 
#   fact that it didn't fail cued me into the error
# * my tests got rushed at the end. not happy about that

require 'minitest/autorun'

describe StringCalculator do
  it "add: returns 0 for ''" do
    StringCalculator.add('').must_equal 0
  end
  
  it "add: returns 1 for '1'" do
    StringCalculator.add('1').must_equal 1
  end

  it "add: returns 3 for '1,2'" do
    StringCalculator.add('1,2').must_equal 3 #katanote
  end

  it "add: throws an error if negatives are included" do
    lambda { StringCalculator.add('1,-1,2') }.must_raise RuntimeError
  end

  it "add: includes the error values if negatives are included" do
    begin
      StringCalculator.add('1,-1,2,-2')
    rescue RuntimeError => e
      e.message.must_equal "negatives not allowed: -1,-2"
    end
  end

  it "numbers: returns [] for ''" do
    obj = StringCalculator.new('')
    obj.numbers.must_equal []
  end

  it "numbers: returns [1] for '1'" do
    obj = StringCalculator.new('1')
    obj.numbers.must_equal [1]
  end

  it "numbers: returns [1,2] for '1,2'" do
    obj = StringCalculator.new('1,2')
    obj.numbers.must_equal [1,2]
  end

  it "numbers: returns [1,2,3] for '1,2,3'" do
    obj = StringCalculator.new('1,2,3')
    obj.numbers.must_equal [1,2,3]
  end

  it "numbers: returns [1,2,3] for '1,2\n3'" do
    obj = StringCalculator.new("1,2\n3")
    obj.numbers.must_equal [1,2,3]
  end

  it "numbers: returns [1,2,3] for '//ab\n1\n2ab3'" do
    obj = StringCalculator.new("//ab\n1\n2ab3")
    obj.numbers.must_equal [1,2,3]
  end

  it "delimiter: returns ',' by default" do
    obj = StringCalculator.new("")
    obj.delimiter.must_equal ','
  end

  it "delimiter: switches based on the first line" do
    obj = StringCalculator.new("//;")
    obj.delimiter.must_equal ';'
  end

  it "delimiter: handles multi character delimiter" do
    obj = StringCalculator.new("//ab")
    obj.delimiter.must_equal 'ab'
  end

  it "valid?: is valid unless there are negatives" do
    obj = StringCalculator.new("")
    obj.valid?.must_equal true

    obj = StringCalculator.new("1")
    obj.valid?.must_equal true

    obj = StringCalculator.new("-1")
    obj.valid?.must_equal false
  end

  it "errors: returns negative numbers" do
    obj = StringCalculator.new("1, -1, 3, -2")
    obj.errors.must_equal [-1,-2]
  end
end
