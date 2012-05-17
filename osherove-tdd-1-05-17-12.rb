require 'minitest/autorun'

module Katas
  class StringCalculator
    attr_writer :parser_source
    def add(str)
      parse(str).reduce(:+)
    end

    def parse(str)
      parser_source.call(str).tap do |values|
        validate(values)
      end
    end

    def validate(values)
      errors = values.select {|i| i<0}
      if errors.any?
        raise ArgumentError.new "negatives not allowed: #{errors}"
      end
    end

    private
    def parser_source
      @parser_source ||= lambda {|str| Parser.parse(str)}
    end
  end

  class Parser
    DEFAULT_DELIMITER = ','
    NEWLINE = "\n"

    def self.parse(input)
      new(input).numbers
    end

    def initialize(input)
      @input = input
    end

    def numbers
      res = items.map(&:to_i)
      res.empty? ? [0] : res
    end

    def lines
      @input.sub(%r|//(.+)\n|, '').split(NEWLINE)
    end

    def items
      lines.map {|line| line.split(delimiter)}.flatten
    end

    def delimiter
      matched = @input.match(%r|//(.+)|)
      (matched && matched.captures[0]) || DEFAULT_DELIMITER
    end
  end
end

# After Kata notes
#
# * chose to spend longer due to realizing this is a practice, not test
# * deliberate tests to push design 
# * don't like how I 'tested' the existence of classes 
# * the code is getting to a stable point, process is becoming focus 
# * Argument error wins over custom error 

include Katas
describe StringCalculator do
  before do
    @it = StringCalculator.new
  end

  it "exists" do
    @it.must_be_kind_of StringCalculator
  end

  it "has an add instance method" do
    @it.method(:add).wont_be_nil
  end

  it "add: takes a string" do
    @it.method(:add).arity.must_equal 1
  end

  it "adds the parsed numbers" do
    @it.parser_source = ->(str) { [1,2,3] }
    @it.add("1,2,3").must_equal 6
  end

  it "throws an error if negative numbers are included" do
    @it.parser_source = ->(str) { [1,-1,-3]}
    lambda { @it.add("1,-1,-3") }.must_raise ArgumentError
  end

  it "includes the error values in the exception message" do
    @it.parser_source = ->(str) { [1,-1,-3]}
    begin
      @it.add("1,-1,-3")
    rescue ArgumentError => e
      e.message.must_match /\[-1, -3\]/
    end
  end

  #integration
  it "adds with newlines" do
    @it.add("1,2\n3").must_equal 6
  end

  # Killed - test parser more than calculator
  # it "add: '' returns 0" do
  #   @it.add('').must_equal 0
  # end

  # it "add: '1' returns 1" do
  #   @it.add('1').must_equal 1
  # end

  # it "add: '1,2' returns 3" do
  #   @it.add('1,2').must_equal 3
  # end
end

describe Parser do
  it "exists and takes a string" do
    Parser.new("").must_be_kind_of Parser
  end

  it "parses '' to [0]" do
    Parser.new('').numbers.must_equal [0]
  end

  it "parses '1' to [1]" do 
    Parser.new('1').numbers.must_equal [1]
  end

  it "parses '1,2' to [1,2]" do
    Parser.new("1,2").numbers.must_equal [1,2]
  end

  it "splits the input into lines" do
    Parser.new("1\n2").lines.must_equal %w[1 2]
  end

  it "combines multiple lines into a list" do
    Parser.new("1\n2,3").items.must_equal %w[1 2 3]
  end

  it "parses with newlines" do
    Parser.new("1\n2,3").numbers.must_equal [1,2,3]
  end

  it "parses from the parse class method" do
    Parser.parse("1\n2,3").must_equal [1,2,3]
  end

  it "defaults to the ',' delimiter" do
    Parser.new('').delimiter.must_equal ','
  end

  it "switches delimiter with '//<new>' syntax" do
    Parser.new("//.").delimiter.must_equal '.'
  end

  it "supports multi char delimiter" do 
    Parser.new("//ab").delimiter.must_equal 'ab'
  end

  it "removes delimiter from the lines" do
    Parser.new("//ab\n1,2\n3").lines.must_equal ["1,2", "3"]
  end

  it "parses with the new delimiter" do
    Parser.new("//ab\n1ab2\n3").numbers.must_equal [1,2,3]
  end
end