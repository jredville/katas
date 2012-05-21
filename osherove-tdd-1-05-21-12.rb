module Katas
  class StringCalculator
    def add(str)
      parse(str).reduce(:+)
    end

    def parse(str)
      Parser.parse(str)
    end
  end

  class Parser
    def self.parse(str)
      res = str.split("\n").map{|line|line.split(',')}.flatten.map(&:to_i)
      res.empty? ? [0] : res
    end
  end
end

require 'minitest/autorun'

describe "Given a instance of the calculator" do
  before do
    @obj = Katas::StringCalculator.new
  end

  it "when I try to add ''" do
    # Then I get 0 as the result
    @obj.add('').must_equal 0
  end


  it "when I try to add '1'" do
    # Then I get 1 as the result
    @obj.add('1').must_equal 1
  end

  it "when I try to add '1,2'" do
    # Then I get 3 as the result
    @obj.add('1,2').must_equal 3
  end

  it "when I try to add '1,2,4'" do
    # Then I get 7 as the result
    @obj.add('1,2,4').must_equal 7
  end

  it "when I try to add '1\n2,3'" do
    # Then I get 6 as the result
    @obj.add("1\n2,3").must_equal 6
  end
end

describe "Given that I need to parse strings" do
  it "when I parse ''" do
    # Then I get [0]
    Katas::Parser.parse('').must_equal [0]
  end

  it "when I parse '1'" do
    # Then I get [1]
    Katas::Parser.parse('1').must_equal [1]
  end

  it "when I parse '1,3'" do
    # Then I get [1,3]
    Katas::Parser.parse('1,3').must_equal [1,3]
  end

  it "when I parse '1\n2,3'" do
    # Then I get [1,2,3]
    Katas::Parser.parse("1\n2,3").must_equal [1,2,3]
  end
end