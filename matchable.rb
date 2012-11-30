require 'delegate'
# Goal: expand the usefulness of case statements by defining a helper method to
#   decorate its argument with a useful #===
#
# Example:
#   case foo
#   when m hash
#     do_hash_op
#   when m method(:foobar)
#     do_method_op
#   when :symbol
#     do_symbol_op
#   when m :symbol
#     do_symbol_call_op
#   when m [:symbol, m symbol, m hash]
#     do_and_op
#   end
module Matchable
  def m(obj)
    decorate(obj)
  end

  private
  def decorate(obj)
    decorators.detect(NotMatchable) do |decorator|
      decorator.decorates? obj
    end.decorate(obj)
  end

  def decorators
    Decorated.decorators
  end

  module Decorated
    def self.decorators
      @decorators ||= []
    end

    def self.included(base)
      decorators << base
      base.extend(ClassMethods)
    end

    module ClassMethods
      def decorate(obj)
        new(obj)
      end
    end

    def decorated?
      true
    end

    def plain
      __getobj__
    end
  end

  # HACK: Laziness
  module NotMatchable
    def call; self; end
    module_function :call
    def decorate(obj); obj; end
    module_function :decorate
  end

  class MatchableSymbol < DelegateClass(Symbol)
    include Decorated
    def self.decorates?(obj)
      obj.is_a? Symbol
    end

    def ===(other)
      other.send(__getobj__)
    end
  end

  class MatchableMethod < DelegateClass(Method)
    include Decorated
    def self.decorates?(obj)
      obj.is_a? Method
    end
    alias_method :===, :call
  end

  class MatchableHash < DelegateClass(Hash)
    include Decorated
    def self.decorates?(obj)
      obj.is_a? Hash
    end
    alias_method :===, :[]
  end
end
require 'minitest/autorun'

describe 'Matchable module' do
  before do
    @matchable = Object.new.extend(Matchable)
  end

  it 'provides the m method' do
    @matchable.respond_to?(:m).must_equal true
  end

  it 'the m method returns an unknown argument' do
    test_obj = Object.new
    @matchable.m(test_obj).must_equal test_obj
  end

  it 'the m method decorates hashes' do
    @matchable.m(Hash.new).decorated?.must_equal true
  end

  it 'the m method decorates method objects' do
    @matchable.m(Object.method(:new)).decorated?.must_equal true
  end

  it 'the m method decorates symbols' do
    @matchable.m(:symbol).decorated?.must_equal true
  end

  it 'can have new matchers added' do
    test_matcher = Class.new(DelegateClass(Fixnum)) do
      include Matchable::Decorated
      def self.decorates?(obj)
        obj == 123
      end
    end

    @matchable.m(123).decorated?.must_equal true
  end
end

describe 'MatchableSymbol' do
  before do
    @matchable = Matchable::MatchableSymbol.new(:nil?)
  end

  it 'is decorated' do
    @matchable.decorated?.must_equal true
  end

  it 'decorates the symbol' do
    @matchable.plain.must_equal :nil?
  end

  it 'translates #=== like a to_proc call' do
    @matchable.===(nil).must_equal true
  end
end

describe 'MatchableMethod' do
  before do
    @method = Object.new.method(:respond_to?)
    @matchable = Matchable::MatchableMethod.new(@method)
  end

  it 'is decorated' do
    @matchable.decorated?.must_equal true
  end

  it 'decorates the method' do
    @matchable.plain.must_equal @method
  end

  # technically, i should probably use a more specific test to confirm
  # that call was called
  it 'translates #=== to #call' do
    @matchable.===(:to_s).must_equal true
  end
end

describe 'MatchableHash' do
  before do
    @hash = {a:'b'}
    @matchable = Matchable::MatchableHash.new(@hash)
  end

  it 'is decorated' do
    @matchable.decorated?.must_equal true
  end

  it 'decorates the hash' do
    @matchable.plain.must_equal @hash
  end

  it 'translates #=== to #[]' do
    @matchable.===(:a).must_equal 'b'
  end
end

describe 'Decorated module' do
  before do
    @plain = Object.new
    @decorated = SimpleDelegator.new(@plain).extend(Matchable::Decorated)
  end

  it 'is decorated' do
    @decorated.decorated?.must_equal true
  end

  it 'can return plain object' do
    @decorated.plain.must_equal @plain
  end
end
